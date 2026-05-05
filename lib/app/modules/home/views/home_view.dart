import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../activity/views/activity_view.dart';
import '../../explore/views/explore_view.dart';
import '../../inbox/views/inbox_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/home_controller.dart';
import '../widgets/custom_bottom_navbar.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const Color _primary = Color(0xFF1E88E5);
  static const Color _exploreFabColor = Color(0xFF6B4EFF);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final int navIndex = controller.selectedNavIndex.value;

      final SystemUiOverlayStyle overlayStyle = navIndex == 0
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle.copyWith(statusBarColor: Colors.transparent),
        child: Scaffold(
          backgroundColor: navIndex == 0 ? _primary : const Color(0xFFF8F9FE),
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
          floatingActionButton: FloatingActionButton(
            onPressed: () => controller.changeNav(2),
            backgroundColor: _exploreFabColor,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.explore_rounded, color: Colors.white, size: 28),
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
    final double topPadding = MediaQuery.of(context).padding.top;

    return Column(
      children: [
        Container(
          color: _primary,
          padding: EdgeInsets.fromLTRB(20, topPadding + 10, 20, 24),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white24,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=150&q=80',
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lokasi Saat Ini', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        SizedBox(height: 2),
                        Text('Surabaya, Jawa Timur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.search, color: Colors.grey),
                          hintText: 'Cari jalan atau area...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FE),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: ListView(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 100),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard('Iklan Aktif', '2 Titik', 'Bulan ini', const Color(0xFFEEF2FF), _primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _summaryCard('Tagihan', '1 Invoice', 'Jatuh tempo', const Color(0xFFFFF7ED), Colors.orange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _categoryItem(Icons.tv_rounded, 'Videotron'),
                      _categoryItem(Icons.picture_in_picture_rounded, 'Baliho'),
                      _categoryItem(Icons.signpost_rounded, 'Signage'),
                      _categoryItem(Icons.grid_view_rounded, 'Lainnya'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Titik Populer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: const Text('Lihat Semua', style: TextStyle(color: _primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        _popularCard(
                          'Jl. Sudirman',
                          'Mulai Rp 15 Jt',
                          'https://images.unsplash.com/photo-1486006920555-c77dcf18193c?auto=format&fit=crop&w=400&q=80',
                        ),
                        _popularCard(
                          'Gatot Subroto',
                          'Mulai Rp 20 Jt',
                          'https://images.unsplash.com/photo-1486006920555-c77dcf18193c?auto=format&fit=crop&w=400&q=80',
                        ),
                        _popularCard(
                          'Kuningan',
                          'Mulai Rp 18 Jt',
                          'https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=400&q=80',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Promo Terbatas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: const Text('Lihat Semua', style: TextStyle(color: _primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 170,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        _promoCard(
                          title: 'Jl. Ahmad Yani',
                          price: 'Rp 12 Jt / bulan',
                          badgeText: 'Diskon 20%',
                          badgeColor: const Color(0xFFFF5252),
                          imageUrl: 'https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=400&q=80',
                        ),
                        _promoCard(
                          title: 'Kawasan Darmo',
                          price: 'Rp 8.5 Jt / bulan',
                          badgeText: 'Tersedia Besok',
                          badgeColor: const Color(0xFFFF9800),
                          imageUrl: 'https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=400&q=80',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Paket Kampanye', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: const Text('Selengkapnya', style: TextStyle(color: _primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _bundleCard(
                    title: 'Kuasai Area CBD',
                    subtitle: '3 Titik Videotron Strategis di Pusat Bisnis',
                    imageUrl: 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?auto=format&fit=crop&w=800&q=80',
                    gradientColors: [_primary.withOpacity(0.9), Colors.transparent],
                  ),
                  _bundleCard(
                    title: 'Paket Mudik Lebaran',
                    subtitle: 'Dominasi Jalur Pantura & Rest Area Tol',
                    imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=800&q=80',
                    gradientColors: [const Color(0xFF0F172A).withOpacity(0.9), Colors.transparent],
                  ),
                ],
              ),
            ),
          ),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _categoryItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: _primary),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _popularCard(String title, String price, String imageUrl) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(12),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(price, style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.85), Colors.transparent],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.flash_on_rounded, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      price,
                      style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
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
  }) {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: gradientColors,
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 40,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'PAKET HEMAT',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.1),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Positioned(
            right: 16,
            bottom: 16,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

}