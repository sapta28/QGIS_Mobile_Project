import 'package:flutter/material.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavbar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  static const Color _bg = Colors.white;
  static const Color _activeColor = Colors.black;
  static const Color _inactiveColor = Color(0xFFB0B8C1);
  static const Color _strokeColor = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        border: const Border(
          top: BorderSide(color: _strokeColor, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false, // Matikan jarak otomatis bawaan HP yang terlalu tinggi
        child: Padding(
          // KUNCI: Berikan jarak manual 8 piksel agar posisi turun tapi TIDAK mepet bezel
          padding: const EdgeInsets.only(bottom: 15), 
          child: SizedBox(
            height: 68, // Tetap menggunakan ukuran 68 agar navbar tetap terlihat GEMUK
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.home_rounded, 'Home', 0),
                _buildNavItem(Icons.receipt_long_rounded, 'Activity', 1),
                
                // Tombol Tengah
                _buildCenterItem(),
                
                _buildNavItem(Icons.chat_bubble_rounded, 'Chat', 3),
                _buildNavItem(Icons.person_rounded, 'Account', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = selectedIndex == index;
    final Color color = isActive ? _activeColor : _inactiveColor;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCenterItem() {
    return GestureDetector(
      onTap: () => onItemTapped(2),
      child: Container(
        width: 72,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFE0FF85), 
              Color(0xFF86EFAC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF86EFAC).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.explore, 
          color: Colors.black, 
          size: 26,
        ),
      ),
    );
  }
}