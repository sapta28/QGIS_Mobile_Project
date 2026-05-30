import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        return null;
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        extendBody: true,
        body: Stack(
          children: [
            const _PageBackground(),
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lihat status booking: active, pending, dan past.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
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
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Color(0xFF0F172A),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final activeIndex = _controller.selectedTab.value;
                    return SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                color: isSelected ? const Color(0xFF059669) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF059669).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: Text(
                                  _tabs[index],
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Obx(() {
                      if (_controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF059669),
                          ),
                        );
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
                        color: const Color(0xFF059669),
                        onRefresh: () => _controller.fetchActivities(
                            status: _statusForTab(_controller.selectedTab.value)),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                          itemCount: bookings.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 48, color: const Color(0xFF64748B).withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            title,
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
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PageBackground extends StatelessWidget {
  const _PageBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF8FAFC),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.5,
            child: Image.network(
              'https://images.unsplash.com/photo-1514565131-fce0801e5785?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Container(
            color: const Color(0xFF059669).withOpacity(0.12),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFD1FAE5).withOpacity(0.95),
                    const Color(0xFFD1FAE5).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: Icon(Icons.cloud_rounded, color: Colors.white.withOpacity(0.9), size: 48),
          ),
          Positioned(
            top: 100,
            left: -15,
            child: Icon(Icons.cloud_rounded, color: Colors.white.withOpacity(0.7), size: 72),
          ),
          Positioned(
            top: 35,
            right: 40,
            child: Icon(Icons.cloud_rounded, color: Colors.white.withOpacity(0.9), size: 36),
          ),
          Positioned(
            top: 85,
            right: -25,
            child: Icon(Icons.cloud_rounded, color: Colors.white.withOpacity(0.8), size: 85),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF8FAFC).withOpacity(0.1),
                  const Color(0xFFF8FAFC).withOpacity(0.85),
                  const Color(0xFFF8FAFC),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}