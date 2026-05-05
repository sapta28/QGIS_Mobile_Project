import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  static const Color _primary = Color(0xFF1E88E5);
  static const Color _background = Color(0xFFF6F7F9);
  static const Color _textPrimary = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: _primary,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                color: _primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: _background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 160),
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFF3F4F6), width: 3),
                              ),
                              child: const CircleAvatar(
                                radius: 50,
                                backgroundColor: Color(0xFFE5E7EB),
                                backgroundImage: NetworkImage(
                                  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=150&q=80',
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'Sapta Adzani',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'PT Smart Ad-Tech',
                            style: TextStyle(
                              fontSize: 12,
                              color: _primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionHeader('Data & Legalitas Perusahaan'),
                      _buildListTile(Icons.location_on_rounded, 'Alamat Perusahaan'),
                      _buildListTile(Icons.receipt_long_rounded, 'NPWP & Data Pajak'),
                      const SizedBox(height: 20),
                      _buildSectionHeader('Pengaturan Akun'),
                      _buildListTile(Icons.manage_accounts_rounded, 'Akun & Keamanan'),
                      _buildSwitchTile(Icons.notifications_rounded, 'Notifikasi', true),
                      const SizedBox(height: 20),
                      _buildSectionHeader('Bantuan & Dukungan'),
                      _buildListTile(Icons.headset_mic_rounded, 'Hubungi Account Manager'),
                      _buildListTile(Icons.help_outline_rounded, 'Pusat Bantuan (FAQ)'),
                      _buildListTile(Icons.gavel_rounded, 'Syarat & Ketentuan'),
                      _buildListTile(Icons.privacy_tip_rounded, 'Kebijakan Privasi'),
                      _buildListTile(Icons.language_rounded, 'Bahasa'),
                      const SizedBox(height: 10),
                      
                      // Bagian Tombol Keluar (Logout) yang sudah diperbarui
                      ElevatedButton(
                        onPressed: () {
                          // Aksi logout di sini
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444), // Background merah
                          foregroundColor: Colors.white, // Icon dan text putih
                          elevation: 0, // Flat design
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.logout_rounded, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Keluar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: _primary, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF4B5563),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF9CA3AF),
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool initialValue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: _primary, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF4B5563),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 24,
            child: Switch(
              value: initialValue,
              onChanged: (value) {},
              activeColor: Colors.white,
              activeTrackColor: _primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFD1D5DB),
            ),
          ),
        ],
      ),
    );
  }
}