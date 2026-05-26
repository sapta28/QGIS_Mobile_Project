import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme.dart';
import '../../../../widgets/booking_card.dart';
import '../bindings/activity_binding.dart';
import '../controllers/activity_controller.dart';
import 'activity_detail_view.dart';

class ActivityView extends StatefulWidget {
  const ActivityView({super.key});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  static const _tabs = ['All', 'Active', 'Pending', 'Past'];

  ActivityController get _controller => Get.find<ActivityController>();

  void _ensureDependencies() {
    if (!Get.isRegistered<ActivityController>()) {
      ActivityBinding().dependencies();
    }
  }

  String? _statusForTab(int index) {
    switch (index) {
      case 0:
        return null; // All
      case 1:
        return 'active';
      case 2:
        return 'pending';
      case 3:
        return 'completed';
      default:
        return null;
    }
  }

  Future<void> _loadTab(int index) async {
    await _controller.fetchActivities(status: _statusForTab(index));
  }

  @override
  void initState() {
    super.initState();
    _ensureDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchActivities(status: null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Bookings',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.02 * 24,
                            color: AppColors.onBackground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lihat status booking: active, pending, dan past.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppColors.onSurface, size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final activeIndex = _controller.selectedTab.value;
              return SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _tabs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = activeIndex == index;
                    return GestureDetector(
                      onTap: () => _loadTab(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected ? null : Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Text(
                          _tabs[index],
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_controller.errorMessage.isNotEmpty) {
                  return _EmptyState(
                    title: 'Gagal memuat data',
                    subtitle: _controller.errorMessage.value,
                    icon: Icons.error_outline_rounded,
                  );
                }

                final bookings = _controller.bookings;
                if (bookings.isEmpty) {
                  final tabLabel = _tabs[_controller.selectedTab.value].toLowerCase();
                  return _EmptyState(
                    title: tabLabel == 'all' ? 'No bookings' : 'No $tabLabel bookings',
                    subtitle: 'Booking pada tab ini belum tersedia.',
                    icon: Icons.calendar_today_outlined,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _controller.fetchActivities(status: _statusForTab(_controller.selectedTab.value)),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return BookingCard(
                        booking: booking,
                        onTap: () {
                          Get.to(() => ActivityDetailView(booking: booking));
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.outline.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
