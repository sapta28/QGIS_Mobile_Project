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
		final paymentInfo = _extractPaymentInfo(item);

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
        isHeldByOthers: false,
				printFee: _toNullableDouble(item['print_fee'] ?? item['mmt_fee'] ?? item['production_fee']),
				installFee: _toNullableDouble(item['install_fee'] ?? item['installation_fee']),
				taxRate: _toNullableDouble(item['tax_rate'] ?? item['vat_rate']),
				downPaymentRate: _toNullableDouble(item['down_payment_rate'] ?? item['dp_rate']),
			),
			startDate: _parseDate(item['start_date']),
			endDate: _parseDate(item['end_date']),
			status: status,
			weeklyImpressions: _toInt(item['impressions_per_day']) * 7,
			totalPrice: _toDouble(item['total_price']),
			rawStatus: rawStatus,
			paymentStatus: paymentInfo['paymentStatus'],
			paymentTerm: paymentInfo['paymentTerm'],
			paymentStage: paymentInfo['paymentStage'],
			checkoutUrl: paymentInfo['checkoutUrl'],
			finalCheckoutUrl: paymentInfo['finalCheckoutUrl'],
			downPaymentAmount: paymentInfo['downPaymentAmount'],
			remainingAmount: paymentInfo['remainingAmount'],
			approvalStatus: paymentInfo['approvalStatus'],
		);
	}

	Map<String, dynamic> _extractPaymentInfo(Map<String, dynamic> item) {
		final payment = _normalizeMap(item['payment']);
		final payments = item['payments'] is List
			? (item['payments'] as List)
					.whereType<Map>()
					.map((value) => value.map((key, value) => MapEntry(key.toString(), value)))
					.toList()
			: <Map<String, dynamic>>[];

		Map<String, dynamic>? dpPayment;
		Map<String, dynamic>? finalPayment;
		Map<String, dynamic>? pendingPayment;

		for (final paymentItem in payments) {
			final term = _asString(paymentItem['type'], fallback: _asString(paymentItem['term']));
			final status = _asString(paymentItem['status']).toLowerCase();
			final isDp = term == 'dp' || term == 'down_payment' || term == 'termin_1';
			final isFinal = term == 'final' || term == 'pelunasan' || term == 'termin_2' || term == 'remaining';
			if (isDp && dpPayment == null) {
				dpPayment = paymentItem;
			}
			if (isFinal && finalPayment == null) {
				finalPayment = paymentItem;
			}
			if (status == 'pending' && pendingPayment == null) {
				pendingPayment = paymentItem;
			}
		}

		final selectedPayment = pendingPayment ?? payment;
		final dpSelected = dpPayment ?? selectedPayment;
		final finalSelected = finalPayment;

		return {
			'paymentStatus': _asString(item['payment_status'], fallback: _asString(selectedPayment['status'])),
			'paymentTerm': _asString(selectedPayment['type'], fallback: _asString(selectedPayment['term'])),
			'paymentStage': _asString(item['payment_stage'], fallback: _asString(selectedPayment['stage'])),
			'checkoutUrl': _extractUrl(selectedPayment),
			'finalCheckoutUrl': _extractUrl(finalSelected),
			'downPaymentAmount': _toNullableDouble(dpSelected['amount'] ?? dpSelected['price']),
			'remainingAmount': _toNullableDouble(finalSelected?['amount'] ?? finalSelected?['price']),
			'approvalStatus': _asString(item['approval_status']),
		};
	}

	Map<String, dynamic> _normalizeMap(Object? value) {
		if (value is Map<String, dynamic>) {
			return value;
		}
		if (value is Map) {
			return value.map((key, value) => MapEntry(key.toString(), value));
		}
		return <String, dynamic>{};
	}

	String? _extractUrl(Map<String, dynamic>? payment) {
		if (payment == null) {
			return null;
		}
		for (final key in const ['checkout_url', 'checkoutUrl', 'payment_url', 'paymentUrl', 'redirect_url']) {
			final value = payment[key];
			if (value is String && value.isNotEmpty) {
				return value;
			}
		}
		return null;
	}

	double? _toNullableDouble(Object? value) {
		if (value == null) {
			return null;
		}
		if (value is num) {
			return value.toDouble();
		}
		return double.tryParse(value.toString());
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
