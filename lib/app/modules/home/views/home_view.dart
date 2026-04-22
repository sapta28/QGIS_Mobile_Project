import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const Color _primary = Color(0xFF33C82C);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final int navIndex = controller.selectedNavIndex.value;

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            _titles[navIndex],
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: IndexedStack(
            index: navIndex,
            children: [
              _buildHomeDashboard(),
              _buildExploreMap(),
              _buildCampaigns(),
              _buildBilling(),
              _buildProfile(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: navIndex,
          onTap: controller.changeNav,
          selectedItemColor: _primary,
          unselectedItemColor: const Color(0xFF64748B),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map_rounded),
              label: 'Eksplorasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              activeIcon: Icon(Icons.campaign_rounded),
              label: 'Kampanye',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Tagihan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      );
    });
  }

  List<String> get _titles => const [
    'Beranda',
    'Eksplorasi Peta',
    'Kampanye',
    'Tagihan',
    'Profil',
  ];

  Widget _buildHomeDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionCard(
          color: const Color(0xFFECFDF5),
          child: const Row(
            children: [
              Icon(Icons.ads_click_rounded, color: _primary, size: 30),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kampanye Aktif',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF065F46),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '2 iklan sedang tayang di Jalan Sudirman dan Gatot Subroto',
                      style: TextStyle(color: Color(0xFF065F46)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          color: const Color(0xFFFFFBEB),
          child: const Row(
            children: [
              Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFFD97706),
                size: 30,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tagihan Mendekati Jatuh Tempo',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Invoice INV-2404-091 jatuh tempo 3 hari lagi',
                      style: TextStyle(color: Color(0xFF92400E)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Rekomendasi Titik Populer',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _sectionCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE2E8F0),
                  child: Text('${index + 1}'),
                ),
                title: Text('Jalan Strategis #${index + 1}'),
                subtitle: const Text('Mulai dari Rp 3.500.000 / bulan'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Promo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF166534),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExploreMap() {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFDCEBFF),
          child: const Center(
            child: Text(
              'Peta GIS Full-Screen',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              Chip(label: Text('Harga: < 5 Juta')),
              Chip(label: Text('Ukuran: Medium')),
              Chip(label: Text('Status: Tersedia')),
            ],
          ),
        ),
        Positioned(
          bottom: 24,
          left: 16,
          right: 16,
          child: _sectionCard(
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Jl. Sudirman - Billboard A12',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('Tap-to-Book tersedia • Rp 7.200.000 / bulan'),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampaigns() {
    final tabs = [
      'Menunggu Pembayaran',
      'Proses Pemasangan',
      'Sedang Tayang',
      'Selesai',
    ];

    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: Obx(
            () => ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final bool active =
                    controller.selectedCampaignTab.value == index;
                return ChoiceChip(
                  label: Text(tabs[index]),
                  selected: active,
                  onSelected: (_) => controller.changeCampaignTab(index),
                  selectedColor: const Color(0xFFDCFCE7),
                  labelStyle: TextStyle(
                    color: active
                        ? const Color(0xFF166534)
                        : const Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: tabs.length,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Obx(
            () => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _sectionCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.storefront_rounded),
                    title: Text(
                      'Order #CMP-${controller.selectedCampaignTab}${index + 1}',
                    ),
                    subtitle: Text(tabs[controller.selectedCampaignTab.value]),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBilling() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionCard(
          color: const Color(0xFFF8FAFC),
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.request_quote_rounded,
              color: Color(0xFF0EA5E9),
            ),
            title: Text('Invoice Belum Dibayar'),
            subtitle: Text('INV-2404-091 • Rp 8.750.000 • Jatuh tempo 3 hari'),
            trailing: Icon(Icons.chevron_right_rounded),
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.history_rounded, color: Color(0xFF6366F1)),
            title: Text('Riwayat Pembayaran'),
            subtitle: Text('Lihat transaksi sebelumnya dan bukti bayar'),
            trailing: Icon(Icons.chevron_right_rounded),
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          color: const Color(0xFFFFFBEB),
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.autorenew_rounded, color: Color(0xFFD97706)),
            title: Text('Perpanjangan Sewa'),
            subtitle: Text('2 slot akan habis masa tayang dalam 7 hari'),
            trailing: Icon(Icons.chevron_right_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildProfile() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionCard(
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Color(0xFFE2E8F0),
              child: Icon(Icons.business_rounded, color: Color(0xFF334155)),
            ),
            title: Text('PT Smart Ad-Tech Indonesia'),
            subtitle: Text('Kelola identitas, NIB, dan NPWP perusahaan'),
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          child: const Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.badge_outlined),
                title: Text('NIB'),
                subtitle: Text('1207000123456'),
              ),
              Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.description_outlined),
                title: Text('NPWP'),
                subtitle: Text('01.234.567.8-901.000'),
              ),
              Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.support_agent_rounded),
                title: Text('Bantuan / CS'),
                subtitle: Text('Hubungi tim support kapan saja'),
                trailing: Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({required Widget child, Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
