import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../data/services/api/auth_token_store.dart';
import '../../../data/services/api/user_api_service.dart';
import '../../../../models/models.dart';

class ActivityController extends GetxController {
	ActivityController(this._userApiService, this._tokenStore);

	final UserApiService _userApiService;
	final AuthTokenStore _tokenStore;

	final bookings = <BookingModel>[].obs;
	final isLoading = false.obs;
	final isSubmitting = false.obs;
	final errorMessage = ''.obs;
	final selectedStatus = 'all'.obs;
	final selectedTab = 0.obs;

	static const String _fallbackImageUrl =
			'https://images.unsplash.com/photo-1546484396-fb3fc6f95f98?w=800&q=80';

	@override
	void onInit() {
		super.onInit();
		fetchActivities();
	}

	Future<void> fetchActivities({String? status}) async {
		if (isLoading.value) {
			return;
		}
		selectedStatus.value = status ?? 'all';
		if (status == null || status == 'all') {
			selectedTab.value = 0;
		} else if (status == 'active') {
			selectedTab.value = 1;
		} else if (status == 'pending') {
			selectedTab.value = 2;
		} else if (status == 'completed' || status == 'past') {
			selectedTab.value = 3;
		}

		final token = _tokenStore.accessToken;
		if (token == null || token.isEmpty) {
			bookings.clear();
			errorMessage.value = 'Sesi login belum tersedia. Silakan login ulang.';
			return;
		}


		isLoading.value = true;
		errorMessage.value = '';
		try {
			final response = await _userApiService.getActivities(status: status);
			final data = response['data'];
			final list = _extractList(data);
			bookings.value = list.map(_mapBooking).toList();
		} catch (error) {
			errorMessage.value =
					_getErrorMessage(error, 'Gagal memuat data aktivitas.');
			Get.snackbar('Activities', errorMessage.value);
		} finally {
			isLoading.value = false;
		}
	}

	Future<bool> cancelActivity({
		required String activityId,
		required String cancelReason,
	}) async {
		if (isSubmitting.value) {
			return false;
		}

		isSubmitting.value = true;
		errorMessage.value = '';
		try {
			await _userApiService.cancelActivity(
				activityId: activityId,
				cancelReason: cancelReason,
			);
			await fetchActivities(status: selectedStatus.value == 'all'
				? null
				: selectedStatus.value);
			return true;
		} catch (error) {
			errorMessage.value = _getErrorMessage(error, 'Gagal membatalkan activity.');
			Get.snackbar('Activities', errorMessage.value);
			return false;
		} finally {
			isSubmitting.value = false;
		}
	}

	List<BookingModel> bookingsForTab(int tabIndex) {
		switch (tabIndex) {
			case 0:
				return bookings.where((item) => item.status == 'active').toList();
			case 1:
				return bookings.where((item) => item.status == 'pending').toList();
			case 2:
				return bookings.where((item) => item.status == 'past').toList();
			default:
				return bookings;
		}
	}

	int countForStatus(String status) {
		return bookings.where((item) => item.status == status).length;
	}

	List<Map<String, dynamic>> _extractList(dynamic data) {
		if (data is Map && data['data'] is List) {
			return List<Map<String, dynamic>>.from(data['data'] as List);
		}
		if (data is List) {
			return List<Map<String, dynamic>>.from(data);
		}
		return <Map<String, dynamic>>[];
	}

	BookingModel _mapBooking(Map<String, dynamic> item) {
		final spot = item['spot'];
		final spotMap = spot is Map ? spot : <String, dynamic>{};
		final rawStatus = _asString(item['status']);
		final status = _mapStatus(rawStatus);

		return BookingModel(
			id: _asString(item['id']),
			referenceId: _asString(item['invoice_no'], fallback: '-'),
			billboard: BillboardModel(
				id: _asString(spotMap['id'], fallback: _asString(item['spot_id'])),
				name: _asString(spotMap['title'], fallback: 'Billboard'),
				location: _asString(item['address'], fallback: '-'),
				city: _asString(item['city'], fallback: '-'),
				imageUrl: _asString(item['thumbnail_url'], fallback: _fallbackImageUrl),
				type: _asString(spotMap['type'], fallback: 'Billboard'),
				pricePerWeek: _toDouble(item['total_price']) / 4.0,
				size: _asString(item['size'], fallback: '-'),
				traffic: _asString(item['traffic_density'], fallback: '-'),
				dailyImpressions: _toInt(item['impressions_per_day']),
				isAvailable: true,
				description: _asString(item['notes'], fallback: ''),
				direction: _asString(item['facing_direction'], fallback: '-'),
				lat: _toDouble(item['latitude']),
				lng: _toDouble(item['longitude']),
			),
			startDate: _parseDate(item['start_date']),
			endDate: _parseDate(item['end_date']),
			status: status,
			weeklyImpressions: _toInt(item['impressions_per_day']) * 7,
			totalPrice: _toDouble(item['total_price']),
			rawStatus: rawStatus,
			checkoutUrl: item['checkout_url'] != null ? _asString(item['checkout_url']) : null,
		);
	}

	DateTime _parseDate(Object? value) {
		if (value is DateTime) {
			return value;
		}
		final parsed = DateTime.tryParse(value?.toString() ?? '');
		return parsed ?? DateTime.now();
	}

	String _mapStatus(String status) {
		switch (status) {
			case 'active':
				return 'active';
			case 'pending':
			case 'pending_payment':
			case 'waiting_confirmation':
			case 'pending_cancel': // Map pending_cancel to pending tab
				return 'pending';
			case 'cancelled':
			case 'completed':
			case 'rejected':
				return 'past';
			default:
				return 'pending';
		}
	}

	String _asString(Object? value, {String fallback = ''}) {
		if (value == null) {
			return fallback;
		}
		final text = value.toString().trim();
		return text.isEmpty ? fallback : text;
	}

	double _toDouble(Object? value) {
		if (value is num) {
			return value.toDouble();
		}
		return double.tryParse(value?.toString() ?? '') ?? 0;
	}

	int _toInt(Object? value) {
		if (value is num) {
			return value.toInt();
		}
		return int.tryParse(value?.toString() ?? '') ?? 0;
	}

	String _getErrorMessage(Object error, String fallback) {
		if (error is DioException) {
			final data = error.response?.data;
			if (data is Map<String, dynamic>) {
				final message = data['message'];
				if (message is String && message.isNotEmpty) {
					return message;
				}
			}
		}
		return fallback;
	}
}
