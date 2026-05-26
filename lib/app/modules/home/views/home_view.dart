import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme.dart';
import '../../activity/views/activity_view.dart';
import '../../explore/views/explore_view.dart';
import '../../inbox/views/inbox_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/home_controller.dart';
import '../widgets/custom_bottom_navbar.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final int navIndex = controller.selectedNavIndex.value;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
        child: Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true,
          body: IndexedStack(
            index: navIndex,
            children: [
              _buildHome(context),
              const ActivityView(),
              const ExploreView(),
              const InboxView(),
              const ProfileView(),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: CustomBottomNavbar(
            selectedIndex: navIndex,
            onItemTapped: controller.changeNav,
          ),
        ),
      );
    });
  }

  Widget _buildHome(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outlineVariant, width: 2),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://ui-avatars.com/api/?name=Sapta+Adzani&background=003ec7&color=fff&size=256',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Location', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text('Surabaya, Jawa Timur', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.onSurface, letterSpacing: -0.5)),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.notifications_rounded, color: AppColors.onSurface, size: 22),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF3B30),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: TextField(
                          style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 14),
                          decoration: InputDecoration(
                            icon: const Icon(Icons.search, color: AppColors.onSurfaceVariant, size: 20),
                            hintText: 'Search street or area...',
                            hintStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.tune_rounded, color: AppColors.onPrimary, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
              children: [
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          'Active Ads',
                          '${controller.activeAdsCount.value} Spots',
                          'This month',
                          AppColors.primaryContainer,
                          AppColors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _summaryCard(
                          'Invoices',
                          '${controller.pendingInvoicesCount.value} Due',
                          'Payment needed',
                          AppColors.errorContainer,
                          AppColors.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _categoryItem(Icons.tv_rounded, 'Videotron'),
                    _categoryItem(Icons.picture_in_picture_rounded, 'Billboard'),
                    _categoryItem(Icons.signpost_rounded, 'Signage'),
                    _categoryItem(Icons.grid_view_rounded, 'More'),
                  ],
                ),
                const SizedBox(height: 32),
                _sectionTitle('Popular Locations'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    children: [
                      _popularCard(
                        'Jl. Sudirman',
                        'From Rp 15 M',
                        'https://images.unsplash.com/photo-1486006920555-c77dcf18193c?auto=format&fit=crop&w=400&q=80',
                      ),
                      _popularCard(
                        'Gatot Subroto',
                        'From Rp 20 M',
                        'https://images.unsplash.com/photo-1486006920555-c77dcf18193c?auto=format&fit=crop&w=400&q=80',
                      ),
                      _popularCard(
                        'Kuningan',
                        'From Rp 18 M',
                        'https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=400&q=80',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _sectionTitle('Limited Promos'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    children: [
                      _promoCard(
                        title: 'Jl. Ahmad Yani',
                        price: 'Rp 12 M / month',
                        badgeText: '20% OFF',
                        badgeColor: AppColors.error,
                        imageUrl: 'https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=400&q=80',
                      ),
                      _promoCard(
                        title: 'Kawasan Darmo',
                        price: 'Rp 8.5 M / month',
                        badgeText: 'Available Tomorrow',
                        badgeColor: const Color(0xFFFF9F0A), // iOS Orange
                        imageUrl: 'https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=400&q=80',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _sectionTitle('Campaign Bundles'),
                const SizedBox(height: 12),
                _bundleCard(
                  title: 'Dominate CBD',
                  subtitle: '3 Strategic Videotrons in Business Center',
                  imageUrl: 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?auto=format&fit=crop&w=800&q=80',
                  gradientColors: [AppColors.primary.withOpacity(0.9), Colors.transparent],
                ),
                _bundleCard(
                  title: 'Holiday Special',
                  subtitle: 'Highway & Rest Area Dominance',
                  imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=800&q=80',
                  gradientColors: [AppColors.surface.withOpacity(0.95), AppColors.surface.withOpacity(0.4)],
                  isDark: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface, letterSpacing: -0.5)),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: Text('See All', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, String subtitle, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(color: textColor.withOpacity(0.8), fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.inter(color: textColor.withOpacity(0.7), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _categoryItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineVariant, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
      ],
    );
  }

  Widget _popularCard(String title, String price, String imageUrl) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Text(price, style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _promoCard({
    required String title,
    required String price,
    required String badgeText,
    required Color badgeColor,
    required String imageUrl,
  }) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.85), Colors.transparent],
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.sell_rounded, color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      price,
                      style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500),
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

  Widget _bundleCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required List<Color> gradientColors,
    bool isDark = true,
  }) {
    final textColor = isDark ? Colors.white : AppColors.onSurface;
    final subColor = isDark ? Colors.white70 : AppColors.onSurfaceVariant;

    return Container(
      height: 150,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: gradientColors,
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 50,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.2) : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.3) : AppColors.outlineVariant),
                  ),
                  child: Text(
                    'SPECIAL BUNDLE',
                    style: GoogleFonts.inter(color: textColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(color: textColor, fontSize: 22, fontWeight: FontWeight.bold, height: 1.1, letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(color: subColor, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: isDark ? Colors.white24 : AppColors.surfaceContainerHigh,
              child: Icon(Icons.arrow_forward_rounded, color: textColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}