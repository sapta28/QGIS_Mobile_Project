import 'package:flutter/material.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavbar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  static const Color _primary = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: EdgeInsets.zero,
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      elevation: 20,
      shadowColor: Colors.black.withOpacity(0.1),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _navItem(Icons.home_outlined, Icons.home_rounded, 'Home', 0),
            ),
            Expanded(
              child: _navItem(Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Activity', 1),
            ),
            Expanded(
              child: _exploreLabel(),
            ),
            Expanded(
              child: _navItem(Icons.inbox_outlined, Icons.inbox_rounded, 'Inbox', 3),
            ),
            Expanded(
              child: _navItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile', 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData outline, IconData solid, String label, int index) {
    final bool isActive = selectedIndex == index;
    final Color color = isActive ? _primary : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isActive ? solid : outline, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _exploreLabel() {
    final bool isActive = selectedIndex == 2;

    return GestureDetector(
      onTap: () => onItemTapped(2),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const SizedBox(height: 2),
          Text(
            'Explore',
            style: TextStyle(
              color: isActive ? _primary : const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}