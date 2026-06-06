import 'package:get/get.dart';

import '../../../data/services/profile_mock_service.dart';

class NotificationsController extends GetxController {
  final _service = ProfileMockService();

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final selectedCategory = 'Semua'.obs;

  final categories = const ['Semua', 'Booking', 'Pembayaran', 'Promo', 'Sistem'];

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get filtered {
    if (selectedCategory.value == 'Semua') return notifications;
    final catMap = {
      'Booking': 'booking',
      'Pembayaran': 'payment',
      'Promo': 'promo',
      'Sistem': 'system',
    };
    final key = catMap[selectedCategory.value];
    return notifications.where((n) => n.category == key).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final result = await _service.getNotifications();
      // Sort: unread first, then by date desc
      result.sort((a, b) {
        if (a.isRead != b.isRead) return a.isRead ? 1 : -1;
        return b.createdAt.compareTo(a.createdAt);
      });
      notifications.assignAll(result);
    } catch (e) {
      // silent
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markRead(String id) async {
    await _service.markNotificationRead(id);
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifications[idx].isRead = true;
      notifications.refresh();
    }
  }

  Future<void> markAllRead() async {
    await _service.markAllNotificationsRead();
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    Get.snackbar('Berhasil', 'Semua notifikasi ditandai sudah dibaca.',
        snackPosition: SnackPosition.BOTTOM);
  }

  void setCategory(String cat) {
    selectedCategory.value = cat;
  }
}
