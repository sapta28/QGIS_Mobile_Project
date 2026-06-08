import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/services/api/user_api_service.dart';
import '../../../../models/models.dart';

class HomeController extends GetxController {
  HomeController(this._userApiService);

  final UserApiService _userApiService;
  final _storage = GetStorage();

  final RxInt selectedNavIndex = 0.obs;
  final RxInt selectedCampaignTab = 0.obs;

  final activeAdsCount = 0.obs;
  final pendingInvoicesCount = 0.obs;
  final isLoadingDashboard = false.obs;
  final errorMessage = ''.obs;
  final campaignBundles = <CampaignBundleModel>[].obs;
  final RxString currentAddress = 'Surabaya, Jawa Timur'.obs;
  final notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardSummary();
    loadDummyCampaignBundles();
    updateCurrentLocation();
    loadNotifications();
  }

  Future<void> refreshHome() async {
    await fetchDashboardSummary();
    await updateCurrentLocation();
    loadNotifications();
  }

  Future<void> updateCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 5),
        );
        final dioClient = Dio();
        dioClient.options.headers['User-Agent'] = 'BillboardPlatformApp/1.0';
        final response = await dioClient.get(
          'https://nominatim.openstreetmap.org/reverse',
          queryParameters: {
            'format': 'json',
            'lat': position.latitude,
            'lon': position.longitude,
            'zoom': 10,
            'addressdetails': 1,
          },
        );
        if (response.statusCode == 200 && response.data != null) {
          final address = response.data['address'];
          if (address != null) {
            final city = address['city'] ?? address['town'] ?? address['village'] ?? address['municipality'] ?? address['county'] ?? '';
            final state = address['state'] ?? '';
            if (city.isNotEmpty && state.isNotEmpty) {
              currentAddress.value = '$city, $state';
            } else if (city.isNotEmpty) {
              currentAddress.value = city.toString();
            } else if (state.isNotEmpty) {
              currentAddress.value = state.toString();
            }
          }
        }
      }
    } catch (e) {
      // Ignore location retrieval errors - fallback to default
    }
  }

  Future<void> fetchDashboardSummary() async {
    if (isLoadingDashboard.value) {
      return;
    }

    isLoadingDashboard.value = true;
    errorMessage.value = '';
    try {
      final response = await _userApiService.getDashboardSummary();
      final data = response['data'];
      if (data is Map) {
        activeAdsCount.value = _toInt(data['active_ads_count']);
        pendingInvoicesCount.value = _toInt(data['pending_invoices_count']);
      }
    } catch (error) {
      errorMessage.value =
          _getErrorMessage(error, 'Gagal memuat ringkasan dashboard.');
      // Silent fail - show default values
    } finally {
      isLoadingDashboard.value = false;
    }
  }

  void changeNav(int index) {
    selectedNavIndex.value = index;
  }

  void changeCampaignTab(int index) {
    selectedCampaignTab.value = index;
  }

  void loadDummyCampaignBundles() {
    const data = [
      CampaignBundleModel(
        title: 'Dominate CBD',
        subtitle: '3 Strategic Videotrons in Business Center',
        imageUrl:
            'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?auto=format&fit=crop&w=600&q=80',
      ),
      CampaignBundleModel(
        title: 'Holiday Special',
        subtitle: 'Highway & Rest Area Dominance',
        imageUrl:
            'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=600&q=80',
      ),
      CampaignBundleModel(
        title: 'Airport Takeover',
        subtitle: 'All digital screens in Terminal 3',
        imageUrl:
            'https://images.unsplash.com/photo-1530521954074-e64f6810b32d?auto=format&fit=crop&w=600&q=80',
      ),
    ];

    campaignBundles.assignAll(data);
  }

  void loadNotifications() {
    try {
      final List<dynamic>? rawList = _storage.read<List<dynamic>>('notifications_list');
      if (rawList != null) {
        notifications.value = rawList
            .map((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        _initializeDefaultNotifications();
      }
    } catch (e) {
      notifications.clear();
    }
  }

  void _initializeDefaultNotifications() {
    final defaultList = [
      NotificationModel(
        id: 'n1',
        title: 'Pembayaran DP Diterima',
        message: 'Pembayaran uang muka untuk Billboard Times Square Spectacular berhasil diverifikasi.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        category: 'payment',
      ),
      NotificationModel(
        id: 'n2',
        title: 'Desain Banner Direview',
        message: 'Materi kreatif iklan Anda untuk Sunset Blvd Digital Hub sedang ditinjau oleh tim admin.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: false,
        category: 'booking',
      ),
      NotificationModel(
        id: 'n3',
        title: 'Kontrak Sewa Selesai',
        message: 'Masa aktif sewa billboard Highway 101 Southbound telah berakhir. Terima kasih telah menggunakan jasa kami.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        category: 'past',
      ),
      NotificationModel(
        id: 'n4',
        title: 'Promo Spesial CBD 15%',
        message: 'Dapatkan potongan harga sewa 15% khusus pemesanan videotron di area perkantoran CBD bulan ini!',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
        category: 'info',
      ),
    ];
    notifications.assignAll(defaultList);
    _saveNotificationsToStorage();
  }

  void _saveNotificationsToStorage() {
    _storage.write('notifications_list', notifications.map((n) => n.toJson()).toList());
  }

  void toggleReadNotification(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final old = notifications[index];
      notifications[index] = NotificationModel(
        id: old.id,
        title: old.title,
        message: old.message,
        timestamp: old.timestamp,
        isRead: !old.isRead,
        category: old.category,
      );
      _saveNotificationsToStorage();
    }
  }

  void markAllAsRead() {
    notifications.value = notifications.map((n) {
      return NotificationModel(
        id: n.id,
        title: n.title,
        message: n.message,
        timestamp: n.timestamp,
        isRead: true,
        category: n.category,
      );
    }).toList();
    _saveNotificationsToStorage();
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    _saveNotificationsToStorage();
  }

  void clearAllNotifications() {
    notifications.clear();
    _saveNotificationsToStorage();
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

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String category;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.category,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
      category: json['category'] ?? 'info',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'category': category,
    };
  }
}
