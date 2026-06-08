import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../widgets/booking_card.dart';
import '../../../../models/models.dart';
import '../../../../widgets/common_widgets.dart';
import '../../../data/services/api/user_api_service.dart';
import '../../activity/views/activity_detail_view.dart';
import '../controllers/profile_controller.dart';

class CampaignHistoryView extends StatefulWidget {
  const CampaignHistoryView({super.key});

  @override
  State<CampaignHistoryView> createState() => _CampaignHistoryViewState();
}

class _CampaignHistoryViewState extends State<CampaignHistoryView> {
  final _profileController = Get.find<ProfileController>();
  final List<BookingModel> _campaigns = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final apiService = Get.find<UserApiService>();
      final response = await apiService.getActivities(status: 'completed');
      final data = response['data'];
      final List<dynamic> list = data is Map && data['data'] is List
          ? List<dynamic>.from(data['data'])
          : (data is List ? List<dynamic>.from(data) : []);

      final mapped = list.map((item) => _mapBooking(Map<String, dynamic>.from(item))).toList();

      if (mounted) {
        setState(() {
          _campaigns.clear();
          _campaigns.addAll(mapped);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat riwayat campaign: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  BookingModel _mapBooking(Map<String, dynamic> item) {
    final spot = item['spot'] is Map ? item['spot'] : <String, dynamic>{};
    final rawStatus = (item['raw_status'] ?? item['status'] ?? '').toString();

    // Map raw status to user tab status
    String status = 'pending';
    if (rawStatus == 'active') {
      status = 'active';
    } else if (rawStatus == 'cancelled' || rawStatus == 'completed' || rawStatus == 'rejected') {
      status = 'past';
    }

    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();
    try {
      if (item['start_date'] != null) startDate = DateTime.parse(item['start_date'].toString());
      if (item['end_date'] != null) endDate = DateTime.parse(item['end_date'].toString());
    } catch (_) {}

    return BookingModel(
      id: (item['id'] ?? '').toString(),
      referenceId: (item['invoice_no'] ?? '-').toString(),
      billboard: BillboardModel(
        id: (spot['id'] ?? item['spot_id'] ?? '').toString(),
        name: (spot['title'] ?? 'Billboard').toString(),
        location: (item['address'] ?? '-').toString(),
        city: (item['city'] ?? '-').toString(),
        imageUrl: (item['thumbnail_url'] ?? spot['thumbnail_url'] ?? 'https://images.unsplash.com/photo-1546484396-fb3fc6f95f98?w=800&q=80').toString(),
        type: (spot['type'] ?? 'Billboard').toString(),
        pricePerWeek: (double.tryParse(item['total_price']?.toString() ?? '0') ?? 0) / 4.0,
        size: (item['size'] ?? '-').toString(),
        traffic: (item['traffic_density'] ?? '-').toString(),
        dailyImpressions: int.tryParse(item['impressions_per_day']?.toString() ?? '0') ?? 0,
        isAvailable: true,
        description: (item['notes'] ?? '').toString(),
        direction: (item['facing_direction'] ?? '-').toString(),
        lat: double.tryParse(item['latitude']?.toString() ?? '0') ?? 0,
        lng: double.tryParse(item['longitude']?.toString() ?? '0') ?? 0,
        isHeldByOthers: false,
      ),
      startDate: startDate,
      endDate: endDate,
      status: status,
      weeklyImpressions: (int.tryParse(item['impressions_per_day']?.toString() ?? '0') ?? 0) * 7,
      totalPrice: double.tryParse(item['total_price']?.toString() ?? '0') ?? 0,
      rawStatus: rawStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(40, 40),
                      ),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF059669),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Campaign History',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.01 * 18,
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  final displayName = _profileController.name.value;
                  final avatarUrl = _profileController.avatarUrl.value;
                  final fallbackAvatar =
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName.isNotEmpty ? displayName : "User")}&background=059669&color=fff&size=128';
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      image: DecorationImage(
                        image: getAvatarProvider(avatarUrl, fallbackAvatar),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF059669),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return _buildEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Terjadi Kesalahan',
        subtitle: _errorMessage,
      );
    }

    if (_campaigns.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFF059669),
        onRefresh: _fetchHistory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: _buildEmptyState(
              icon: Icons.history_rounded,
              title: 'Tidak ada campaign history',
              subtitle: 'Aktivitas sewa billboard yang sudah selesai akan muncul di sini.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF059669),
      onRefresh: _fetchHistory,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        itemCount: _campaigns.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final booking = _campaigns[index];
          return BookingCard(
            booking: booking,
            onTap: () {
              Get.to(() => ActivityDetailView(booking: booking));
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
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
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 48,
                color: const Color(0xFF94A3B8),
              ),
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
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
