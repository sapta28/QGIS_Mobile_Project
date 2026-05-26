import 'package:flutter/material.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavbar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  // Warna hijau untuk background kapsul utama
  static const Color _greenBackground = Color(0xFF20C583);
  
  // Warna ikon reguler (putih)
  static const Color _iconActive = Colors.white;
  static const Color _iconInactive = Colors.white60;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Container(
          height: 64, 
          decoration: BoxDecoration(
            color: _greenBackground, 
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 0. Home
              _buildNavItem(Icons.home_outlined, Icons.home_rounded, 0),
              
              // 1. Activity
              _buildNavItem(Icons.receipt_long_outlined, Icons.receipt_long_rounded, 1),
              
              // 2. Explore (Tengah - Lingkaran Putih Besar)
              _buildCenterItem(),
              
              // 3. Chat
              _buildNavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 3),
              
              // 4. Profile
              _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 4),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk menu biasa (icon only)
  Widget _buildNavItem(IconData outline, IconData solid, int index) {
    final bool isActive = selectedIndex == index;
    final Color color = isActive ? _iconActive : _iconInactive;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Icon(
          isActive ? solid : outline,
          color: color,
          size: 26,
        ),
      ),
    );
  }

  // Widget khusus untuk menu Explore di tengah (Lingkaran Putih Besar)
  Widget _buildCenterItem() {
    return GestureDetector(
      onTap: () => onItemTapped(2),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white, // Lingkaran besar berwarna putih
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.explore, 
          color: _greenBackground, // Ikon kompas berwarna hijau agar kontras dengan latar putihnya
          size: 28, 
        ),
      ),
    );
  }
}