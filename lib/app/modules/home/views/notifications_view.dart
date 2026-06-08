import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../widgets/common_widgets.dart';
import '../controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final _homeController = Get.find<HomeController>();
  final _profileController = Get.find<ProfileController>();
  
  // 0 = All, 1 = Unread
  int _selectedFilterTab = 0;

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit yang lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    } else {
      return '${diff.inDays} hari yang lalu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(40, 40),
                      ),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF059669),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Notifications',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.01 * 18,
                      ),
                    ),
                  ],
                ),
                 Obx(() {
                  final displayName = _profileController.name.value;
                  final avatarUrl = _profileController.avatarUrl.value;
                  final fallbackAvatar =
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName.isNotEmpty ? displayName : "User")}&background=059669&color=fff&size=128';
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      image: DecorationImage(
                        image: getAvatarProvider(avatarUrl, fallbackAvatar),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Obx(() {
              final allList = _homeController.notifications;
              final list = _selectedFilterTab == 0
                  ? allList
                  : allList.where((n) => !n.isRead).toList();

              return RefreshIndicator(
                color: const Color(0xFF059669),
                onRefresh: () async {
                  _homeController.loadNotifications();
                },
                child: list.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: _buildEmptyState(),
                        ),
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final notification = list[index];
                          return _buildNotificationCard(notification);
                        },
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildFilterTabButton(0, 'Semua'),
              const SizedBox(width: 8),
              _buildFilterTabButton(1, 'Belum Dibaca'),
            ],
          ),
          Obx(() {
            final hasUnread = _homeController.notifications.any((n) => !n.isRead);
            if (!hasUnread) return const SizedBox.shrink();
            return TextButton.icon(
              onPressed: _homeController.markAllAsRead,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                foregroundColor: const Color(0xFF059669),
              ),
              icon: const Icon(Icons.done_all_rounded, size: 16),
              label: Text(
                'Tandai dibaca',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterTabButton(int index, String label) {
    final isSelected = _selectedFilterTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF059669) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? const Color(0xFF059669) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_off_rounded,
                size: 48,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada notifikasi',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilterTab == 0
                  ? 'Semua pemberitahuan dan info promo terbaru akan muncul di sini.'
                  : 'Hebat! Anda telah membaca semua notifikasi terbaru.',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (notification.category) {
      case 'payment':
        icon = Icons.payments_outlined;
        iconColor = const Color(0xFF059669);
        iconBg = const Color(0xFFECFDF5);
        break;
      case 'booking':
        icon = Icons.calendar_today_outlined;
        iconColor = const Color(0xFF3B82F6);
        iconBg = const Color(0xFFEFF6FF);
        break;
      case 'info':
        icon = Icons.discount_outlined;
        iconColor = const Color(0xFFF59E0B);
        iconBg = const Color(0xFFFEF3C7);
        break;
      default:
        icon = Icons.notifications_none_rounded;
        iconColor = const Color(0xFF64748B);
        iconBg = const Color(0xFFF1F5F9);
    }

    return Container(
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead ? const Color(0xFFE2E8F0) : const Color(0xFFD1FAE5),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF059669),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.4,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => _homeController.toggleReadNotification(notification.id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        notification.isRead ? Icons.mark_as_unread_outlined : Icons.mark_email_read_outlined,
                        size: 18,
                        color: const Color(0xFF64748B),
                      ),
                      tooltip: notification.isRead ? 'Tandai belum dibaca' : 'Tandai sudah dibaca',
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () => _homeController.deleteNotification(notification.id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Color(0xFFEF4444),
                      ),
                      tooltip: 'Hapus notifikasi',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
