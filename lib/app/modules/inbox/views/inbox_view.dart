import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/inbox_controller.dart';

class InboxView extends GetView<InboxController> {
  const InboxView({Key? key}) : super(key: key);

  static const Color _primary = Color(0xFF1E88E5);
  static const Color _background = Color(0xFFF6F7F9);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF9CA3AF);
  static const Color _badgeGreen = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: _primary,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F7F9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    _buildSearch(),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) => _buildChatTile(_items[index]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, topPadding + 10, 20, 20),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Chats',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: const [
            Icon(Icons.search, color: _textMuted, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Search here...',
                style: TextStyle(color: _textMuted, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(_InboxItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(item.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: _textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.time,
                style: const TextStyle(fontSize: 12, color: _textMuted),
              ),
              const SizedBox(height: 8),
              if (item.unreadCount > 0)
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _badgeGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${item.unreadCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InboxItem {
  final String name;
  final String preview;
  final String time;
  final int unreadCount;
  final String avatarUrl;

  const _InboxItem({
    required this.name,
    required this.preview,
    required this.time,
    required this.unreadCount,
    required this.avatarUrl,
  });
}

const List<_InboxItem> _items = [
  _InboxItem(
    name: 'John Smith',
    preview: 'How are you?',
    time: 'Just now',
    unreadCount: 0,
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&q=80',
  ),
  _InboxItem(
    name: 'Richard Wright',
    preview: 'Will you come to the party on saturd...',
    time: '20 min ago',
    unreadCount: 3,
    avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=120&q=80',
  ),
  _InboxItem(
    name: 'Amanda Parkers',
    preview: 'Wanna go outside someday?',
    time: '11:02 AM',
    unreadCount: 1,
    avatarUrl: 'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?auto=format&fit=crop&w=120&q=80',
  ),
  _InboxItem(
    name: 'Wade Warren',
    preview: 'Typing...',
    time: '9:27 AM',
    unreadCount: 0,
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80',
  ),
  _InboxItem(
    name: 'Esther Howard',
    preview: 'Great, I will try to fix the meeting & let...',
    time: 'May 10',
    unreadCount: 0,
    avatarUrl: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=120&q=80',
  ),
  _InboxItem(
    name: 'Carly Mensch',
    preview: 'Thank you so much! Let\'s meet today.',
    time: 'May 15',
    unreadCount: 0,
    avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=120&q=80',
  ),
  _InboxItem(
    name: 'Albert Flores',
    preview: 'Thank you so much! Let\'s meet today.',
    time: 'May 11',
    unreadCount: 0,
    avatarUrl: 'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?auto=format&fit=crop&w=120&q=80',
  ),
];
