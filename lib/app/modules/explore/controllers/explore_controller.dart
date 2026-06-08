import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../data/services/api/user_api_service.dart';
import '../../../../models/models.dart';

class ExploreController extends GetxController {
	ExploreController(this._userApiService);

	final UserApiService _userApiService;

	final billboards = <BillboardModel>[].obs;
	final filteredBillboards = <BillboardModel>[].obs;  // Reactive list yang digunakan UI
	final isLoading = false.obs;
	final errorMessage = ''.obs;

	final selectedCategory = RxnString();
	final searchQuery = ''.obs;
	Timer? _pollingTimer;

	/// Terapkan filter + search ke filteredBillboards
	void _applyFilter() {
		final query = searchQuery.value.toLowerCase().trim();
		final category = selectedCategory.value;

		filteredBillboards.value = billboards.where((b) {
			final matchesCategory = category == null ||
					b.type.toLowerCase().contains(category.toLowerCase());
			final matchesSearch = query.isEmpty ||
					b.name.toLowerCase().contains(query) ||
					b.location.toLowerCase().contains(query) ||
					b.city.toLowerCase().contains(query) ||
					b.type.toLowerCase().contains(query);
			return matchesCategory && matchesSearch;
		}).toList();
	}

	void setCategoryFilter(String category) {
		selectedCategory.value = category;
	}

	void clearCategoryFilter() {
		selectedCategory.value = null;
	}

	void setSearchQuery(String query) {
		searchQuery.value = query;
	}

	void clearSearch() {
		searchQuery.value = '';
	}

	@override
	void onInit() {
		super.onInit();
		fetchSpots();
		// Saat source data berubah → terapkan filter ulang
		ever(billboards, (_) => _applyFilter());
		// Saat kriteria filter berubah → terapkan filter ulang
		ever(searchQuery, (_) => _applyFilter());
		ever(selectedCategory, (_) => _applyFilter());
		// Auto-polling setiap 30 detik (background, tidak tampilkan loading indicator)
		_pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
			fetchSpots(silent: true);
		});
	}

	@override
	void onClose() {
		_pollingTimer?.cancel();
		super.onClose();
	}

	Future<void> fetchSpots({
		double? lat,
		double? lng,
		int? radius,
		String? query,
		bool silent = false,
	}) async {
		// Jika silent mode (polling background), jangan tampilkan loading spinner
		if (!silent) {
			if (isLoading.value) return;
			isLoading.value = true;
		}

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
			if (!silent) {
				errorMessage.value = _getErrorMessage(error, 'Gagal memuat data spot.');
				Get.snackbar('Explore', errorMessage.value);
			}
		} finally {
			if (!silent) isLoading.value = false;
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
      isHeldByOthers: false,
			printFee: _toNullableDouble(item['print_fee'] ?? item['mmt_fee'] ?? item['production_fee']),
			installFee: _toNullableDouble(item['install_fee'] ?? item['installation_fee']),
			taxRate: _toNullableDouble(item['tax_rate'] ?? item['vat_rate']),
			downPaymentRate: _toNullableDouble(item['down_payment_rate'] ?? item['dp_rate']),
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

	double? _toNullableDouble(Object? value) {
		if (value == null) {
			return null;
		}
		if (value is num) {
			return value.toDouble();
		}
		return double.tryParse(value.toString());
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
