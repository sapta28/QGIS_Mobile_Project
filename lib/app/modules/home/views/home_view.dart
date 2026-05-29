import 'dart:math' as math; // Impor math untuk logika pembatasan item
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
          backgroundColor: const Color(0xFFF8FAFC),
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
    return Stack(
      children: [
        const _PageBackground(),
        SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'My Location',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFF059669),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Surabaya, Jawa Timur',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: Color(0xFF0F172A),
                            size: 22,
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const _BannerSlider(),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Active Ads',
                          value: controller.activeAdsCount.value.toString(),
                          subtitle1: 'Spots Aktif',
                          subtitle2: 'Bulan ini',
                          iconData: Icons.insert_chart_rounded,
                          iconGradientColors: const [Color(0xFF34D399), Color(0xFF059669)],
                          primaryColor: const Color(0xFF059669),
                          watermarkIcon: Icons.tv_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Invoices',
                          value: controller.pendingInvoicesCount.value.toString(),
                          subtitle1: 'Due',
                          subtitle2: 'Pembayaran diperlukan',
                          iconData: Icons.description_rounded,
                          iconGradientColors: const [Color(0xFFF43F5E), Color(0xFFE11D48)],
                          primaryColor: const Color(0xFFE11D48),
                          watermarkIcon: Icons.request_quote_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // ---- BAGIAN CAMPAIGN BUNDLES (VERTIKAL) ----
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Campaign Bundles',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Obx(() {
                      if (controller.campaignBundles.length > 2) {
                        return TextButton(
                          onPressed: () {
                            // Get.toNamed('/all-campaigns');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'See All',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF059669),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
              Obx(() => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: math.min(controller.campaignBundles.length, 2),
                itemBuilder: (context, index) {
                  final bundle = controller.campaignBundles[index];
                  return _buildCampaignBundleCard(
                    title: bundle.title,
                    subtitle: bundle.subtitle,
                    imageUrl: bundle.imageUrl,
                  );
                },
              )),
              // ---- AKHIR BAGIAN CAMPAIGN BUNDLES ----
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                child: Text(
                  'Jenis Media',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(
                height: 190,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: [
                    _buildCategoryCard(
                      title: 'Billboard Statis',
                      description: 'Media cetak berkualitas\ndengan visibilitas tinggi',
                      iconBgColor: const Color(0xFFDCFCE7),
                      iconData: Icons.picture_in_picture_alt_rounded,
                      iconColor: const Color(0xFF16A34A),
                    ),
                    _buildCategoryCard(
                      title: 'Videotron',
                      description: 'Konten dinamis, tampilan\nvideo yang menarik',
                      iconBgColor: const Color(0xFFE0F2FE),
                      iconData: Icons.play_circle_filled_rounded,
                      iconColor: const Color(0xFF0284C7),
                    ),
                    _buildCategoryCard(
                      title: 'LED Display',
                      description: 'Teknologi modern untuk\ntampilan terbaik',
                      iconBgColor: const Color(0xFFFFEDD5),
                      iconData: Icons.developer_board_rounded,
                      iconColor: const Color(0xFFEA580C),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                child: Text(
                  'Lokasi Populer',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: [
                    _popularCard(
                      'Jl. Sudirman',
                      'Mulai dari\nRp 15 M',
                      'https://images.unsplash.com/photo-1486006920555-c77dcf18193c?auto=format&fit=crop&w=400&q=80',
                      'Populer',
                      const Color(0xFFEF4444),
                    ),
                    _popularCard(
                      'Gatot Subroto',
                      'Mulai dari\nRp 20 M',
                      'https://images.unsplash.com/photo-1486006920555-c77dcf18193c?auto=format&fit=crop&w=400&q=80',
                      'Terlaris',
                      const Color(0xFF10B981),
                    ),
                    _popularCard(
                      'Kertajaya',
                      'Mulai dari\nRp 18 M',
                      'https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=400&q=80',
                      'Baru',
                      const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle1,
    required String subtitle2,
    required IconData iconData,
    required List<Color> iconGradientColors,
    required Color primaryColor,
    required IconData watermarkIcon,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PhysicalShape(
          color: Colors.white,
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.2),
          clipper: const TopRightCutoutClipper(),
          child: SizedBox(
            height: 124,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Opacity(
                    opacity: 0.05,
                    child: Icon(
                      watermarkIcon,
                      size: 80,
                      color: primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: iconGradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: iconGradientColors[0].withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(iconData, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF0F172A),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          const SizedBox(width: 32),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        value,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0F172A),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle1,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0F172A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle2,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF64748B),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: primaryColor,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  // ---- WIDGET CARD BARU UNTUK BUNDLE ----
  Widget _buildCampaignBundleCard({
    required String title,
    required String subtitle,
    required String imageUrl,
  }) {
    return Container(
      width: double.infinity,
      height: 160,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String description,
    required Color iconBgColor,
    required IconData iconData,
    required Color iconColor,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              color: const Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 9,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF059669),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _popularCard(String title, String price, String imageUrl, String badgeText, Color badgeColor) {
    return Container(
      width: 160,
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
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Colors.white, size: 10),
                  const SizedBox(width: 4),
                  Text(
                    badgeText,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                ],
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    price,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600, height: 1.2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white70, size: 10),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Surabaya',
                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 12),
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

class _BannerSlider extends StatefulWidget {
  const _BannerSlider();

  @override
  State<_BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<_BannerSlider> {
  late PageController _pageController;
  int _currentIndex = 0;
  final int _initialPage = 4998;

  final List<Map<String, dynamic>> _slides = [
    {
      'tag': 'Premium',
      'title': 'Temukan Lokasi Billboard\nTerbaik untuk Brand Anda',
      'subtitle': 'Jangkau audiens lebih luas di lokasi\nstrategis dengan data akurat.',
      'imageUrl': 'https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=400&q=80',
      'colors': [const Color(0xFF064E3B), const Color(0xFF059669)],
    },
    {
      'tag': 'Baru',
      'title': 'Videotron Interaktif\ndi Pusat Kota',
      'subtitle': 'Tingkatkan engagement pelanggan\ndengan visual yang dinamis.',
      'imageUrl': 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?auto=format&fit=crop&w=400&q=80',
      'colors': [const Color(0xFF1E1B4B), const Color(0xFF4F46E5)],
    },
    {
      'tag': 'Eksklusif',
      'title': 'Dominasi Jalan Tol\ndengan Mega Signage',
      'subtitle': 'Jangkau jutaan pasang mata\nsetiap hari dengan visibilitas tinggi.',
      'imageUrl': 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=400&q=80',
      'colors': [const Color(0xFF7F1D1D), const Color(0xFFEF4444)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.86,
      initialPage: _initialPage,
    );
    _currentIndex = _initialPage % _slides.length;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index % _slides.length;
              });
            },
            itemCount: 10000,
            itemBuilder: (context, index) {
              final slideIndex = index % _slides.length;
              final slide = _slides[slideIndex];

              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.06)).clamp(0.0, 1.0);
                  } else {
                    value = (index == _initialPage) ? 1.0 : 0.94;
                  }
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: slide['colors'] as List<Color>,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (slide['colors'] as List<Color>)[1].withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        bottom: -20,
                        child: Opacity(
                          opacity: 0.4,
                          child: Image.network(
                            slide['imageUrl'] as String,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (slide['colors'] as List<Color>)[0].withOpacity(0.95),
                              Colors.transparent,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    slide['tag'] as String,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              slide['title'] as String,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              slide['subtitle'] as String,
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => _buildDotIndicator(index == _currentIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class TopRightCutoutClipper extends CustomClipper<Path> {
  const TopRightCutoutClipper();

  @override
  Path getClip(Size size) {
    Path path = Path();
    double r = 20.0;
    
    path.moveTo(r, 0);
    path.lineTo(size.width - 54, 0);
    path.quadraticBezierTo(size.width - 42, 0, size.width - 42, 12);
    path.arcToPoint(
      Offset(size.width - 12, 42),
      radius: const Radius.circular(24),
      clockwise: false,
    );
    path.quadraticBezierTo(size.width, 42, size.width, 54);
    path.lineTo(size.width, size.height - r);
    path.arcToPoint(Offset(size.width - r, size.height), radius: Radius.circular(r), clockwise: true);
    path.lineTo(r, size.height);
    path.arcToPoint(Offset(0, size.height - r), radius: Radius.circular(r), clockwise: true);
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r), clockwise: true);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}