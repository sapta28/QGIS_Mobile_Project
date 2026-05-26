import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../data/services/api/user_api_service.dart';
import '../../../../models/models.dart';

class ExploreController extends GetxController {
	ExploreController(this._userApiService);

	final UserApiService _userApiService;

	final billboards = <BillboardModel>[].obs;
	final isLoading = false.obs;
	final errorMessage = ''.obs;

	@override
	void onInit() {
		super.onInit();
		fetchSpots();
	}

	Future<void> fetchSpots({
		double? lat,
		double? lng,
		int? radius,
		String? query,
	}) async {
		if (isLoading.value) {
			return;
		}

		isLoading.value = true;
		errorMessage.value = '';
		try {
			final response = await _userApiService.getSpots(
				lat: lat,
				lng: lng,
				radius: radius,
				query: query,
			);

			final data = response['data'];
			final list = _extractList(data);
			billboards.value = list.map(_mapSpot).toList();
		} catch (error) {
			errorMessage.value = _getErrorMessage(error, 'Gagal memuat data spot.');
			Get.snackbar('Explore', errorMessage.value);
		} finally {
			isLoading.value = false;
		}
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

	BillboardModel _mapSpot(Map<String, dynamic> item) {
		final pricePerMonth = _toDouble(item['price_per_month']);
		return BillboardModel(
			id: _asString(item['id']),
			name: _asString(item['title'], fallback: 'Untitled Billboard'),
			location: _asString(item['address'], fallback: 'Unknown Location'),
			city: _asString(item['city'], fallback: '-'),
			imageUrl: _asString(
				item['thumbnail_url'],
				fallback:
						'https://images.unsplash.com/photo-1546484396-fb3fc6f95f98?w=800&q=80',
			),
			type: _asString(item['category'], fallback: 'Billboard'),
			pricePerWeek: pricePerMonth > 0 ? pricePerMonth : 0,
			size: _asString(item['size'], fallback: '-'),
			traffic: _asString(item['traffic_density'], fallback: '-'),
			dailyImpressions: _toInt(item['impressions_per_day']),
			isAvailable: item['is_available'] == true,
			description: _asString(item['description'], fallback: ''),
			direction: _asString(item['facing_direction'], fallback: '-'),
			lat: _toDouble(item['latitude']),
			lng: _toDouble(item['longitude']),
		);
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
