import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme.dart';
import '../../../../models/models.dart';
import '../../../../widgets/common_widgets.dart';
import '../../../data/services/api/user_api_service.dart';
import 'booking_confirmation_screen.dart';

class BillboardDetailScreen extends StatelessWidget {
  final BillboardModel billboard;

  const BillboardDetailScreen({super.key, required this.billboard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Image
              SliverToBoxAdapter(
                child: _HeroImageSection(billboard: billboard),
              ),
              // Detail Sheet
              SliverToBoxAdapter(
                child: _DetailSheet(billboard: billboard),
              ),
              // Bottom padding for sticky button
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          // Sticky Book Now Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _StickyBookButton(billboard: billboard),
          ),
        ],
      ),
    );
  }
}

class _HeroImageSection extends StatelessWidget {
  final BillboardModel billboard;
  const _HeroImageSection({required this.billboard});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hero Image
          CachedNetworkImage(
            imageUrl: billboard.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.surfaceContainerHigh,
              child: const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.surfaceContainerHigh,
              child: const Icon(Icons.image, color: AppColors.outline, size: 64),
            ),
          ),
          // Top gradient for button contrast
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black45, Colors.transparent],
                ),
              ),
            ),
          ),
          // Floating action buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleIconButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CircleIconButton(
                  icon: Icons.share_outlined,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  final BillboardModel billboard;
  const _DetailSheet({required this.billboard});

  String _formatImpressions() {
    final val = billboard.dailyImpressions;
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}M';
    if (val >= 1000) return '${(val / 1000).round()}k';
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 30,
              offset: Offset(0, -8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge and price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    billboard.isAvailable ? 'Available Now' : 'Not Available',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.05 * 12,
                      color: billboard.isAvailable
                          ? AppColors.primary
                          : AppColors.outline,
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '\$${(billboard.pricePerWeek).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.01 * 18,
                        ),
                      ),
                      TextSpan(
                        text: ' / wk',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              billboard.name,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.02 * 24,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            // Location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 18, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${billboard.location}, ${billboard.city}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        billboard.direction,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.outlineVariant, height: 1),
            const SizedBox(height: 16),
            // Specs Bento Grid
            Row(
              children: [
                Expanded(
                  child: BillboardSpecCard(
                    icon: Icons.aspect_ratio,
                    iconColor: AppColors.onSurfaceVariant,
                    label: 'SIZE',
                    value: billboard.size,
                    subtitle: 'Digital Bulletin',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BillboardSpecCard(
                    icon: Icons.trending_up,
                    iconColor: AppColors.secondary,
                    label: 'TRAFFIC',
                    value: billboard.traffic,
                    subtitle: '${_formatImpressions()} Daily Impr.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Description
            Text(
              'About this location',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.01 * 18,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              billboard.description,
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.6,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BillboardSpecCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;

  const BillboardSpecCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.05 * 11,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.01 * 18,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyBookButton extends StatelessWidget {
  final BillboardModel billboard;
  const _StickyBookButton({required this.billboard});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withOpacity(0.95),
        border: const Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: PrimaryButton(
        label: 'Book Now',
        trailingIcon: Icons.arrow_forward,
        onPressed: () {
          Get.to(
            () => BookingScreen(billboard: billboard),
            transition: Transition.rightToLeft,
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Full-screen Booking Screen
// ──────────────────────────────────────────────────────────────────────────────

class BookingScreen extends StatefulWidget {
  final BillboardModel billboard;
  const BookingScreen({super.key, required this.billboard});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _notesController = TextEditingController();

  DateTime? _startDate;
  int _months = 1;          // jumlah bulan sewa
  bool _isSubmitting = false;
  String? _uploadedFileName;

  UserApiService get _userApiService => Get.find<UserApiService>();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _formatImpressions() {
    final val = widget.billboard.dailyImpressions;
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}M';
    if (val >= 1000) return '${(val / 1000).round()}k';
    return val.toString();
  }

  /// End date = start date + _months months (minus 1 day so range is inclusive)
  DateTime? get _endDate {
    if (_startDate == null) return null;
    final start = _startDate!;
    // Add _months months
    int newMonth = start.month + _months;
    int newYear = start.year + (newMonth - 1) ~/ 12;
    newMonth = ((newMonth - 1) % 12) + 1;
    final rawEnd = DateTime(newYear, newMonth, start.day);
    // Subtract 1 day so start+1month-1day = last day of rental
    return rawEnd.subtract(const Duration(days: 1));
  }

  String _displayDate(DateTime? value) {
    if (value == null) return 'dd/mm/yyyy';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dd = value.day.toString().padLeft(2, '0');
    return '$dd ${months[value.month - 1]} ${value.year}';
  }

  String _apiDate(DateTime? value) {
    if (value == null) return '';
    final mm = value.month.toString().padLeft(2, '0');
    final dd = value.day.toString().padLeft(2, '0');
    return '${value.year}-$mm-$dd';
  }

  /// Monthly rate = pricePerWeek * 4.33 (average weeks per month)
  double get _monthlyRate => widget.billboard.pricePerWeek * (30 / 7);

  double get _totalPrice => _monthlyRate * _months;

  String _formatMoney(double amount) =>
      '\$${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String _getErrorMessage(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) return message;
      }
    }
    return fallback;
  }

  // ── Date Picker ───────────────────────────────────────────────────────────────

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _startDate = picked);
  }

  // ── Submit ───────────────────────────────────────────────────────────────────

  Future<void> _submitBooking() async {
    if (_isSubmitting) return;
    if (_startDate == null) {
      Get.snackbar('Booking', 'Pilih tanggal mulai terlebih dahulu.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await _userApiService.bookSpot(
        spotId: widget.billboard.id,
        startDate: _apiDate(_startDate),
        endDate: _apiDate(_endDate),
        durationType: 'monthly',
        durationValue: _months,
        notes: _notesController.text.trim(),
      );

      // Extract reference ID from response if available
      String refId = 'BKG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      if (response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          refId = (data['reference_id'] ?? data['id']?.toString() ?? refId).toString();
        }
      }

      // Navigate to confirmation screen (replaces booking screen in stack)
      Get.off(
        () => BookingConfirmationScreen(
          billboardName: widget.billboard.name,
          startDate: _displayDate(_startDate),
          endDate: _displayDate(_endDate),
          referenceId: refId,
        ),
        transition: Transition.fade,
      );
    } catch (error) {
      final message = _getErrorMessage(error, 'Gagal membuat booking.');
      Get.snackbar('Booking', message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // ── Top App Bar ──────────────────────────────────────────────────────
          _buildHeader(context),
          // ── Scrollable Body ──────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBillboardSummary(),
                  const SizedBox(height: 24),
                  _buildCampaignDates(),
                  const SizedBox(height: 24),
                  _buildCreativeUpload(),
                  const SizedBox(height: 24),
                  _buildAdditionalNotes(),
                  const SizedBox(height: 24),
                  _buildPriceSummary(),
                  const SizedBox(height: 24),
                  _buildConfirmButton(),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.surface.withOpacity(0.9),
      padding: EdgeInsets.fromLTRB(
          4, MediaQuery.of(context).padding.top + 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 24),
            color: AppColors.onSurface,
            splashRadius: 22,
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Text(
              'Book Billboard',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.01 * 20,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Billboard Summary Card ────────────────────────────────────────────────────

  Widget _buildBillboardSummary() {
    final b = widget.billboard;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 30,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: CachedNetworkImage(
                imageUrl: b.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.surfaceContainerHigh,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceContainerHigh,
                  child: const Icon(Icons.image,
                      color: AppColors.outline, size: 32),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    b.type,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.05 * 12,
                      color: AppColors.onPrimaryFixed,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Name
                Text(
                  b.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.01 * 16,
                    color: AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Location
                Text(
                  '${b.location}, ${b.city}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Impressions
                Row(
                  children: [
                    const Icon(Icons.visibility,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatImpressions()} / day',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
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

  // ── Campaign Dates ────────────────────────────────────────────────────────────

  Widget _buildCampaignDates() {
    final end = _endDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durasi Sewa',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01 * 20,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // ── Tanggal Mulai ──────────────────────────────────────────────────
        Text(
          'Tanggal Mulai',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickStartDate,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _startDate != null
                    ? AppColors.primary
                    : AppColors.outlineVariant,
                width: _startDate != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: _startDate != null
                      ? AppColors.primary
                      : AppColors.outline,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _displayDate(_startDate),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: _startDate != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: _startDate != null
                          ? AppColors.onSurface
                          : AppColors.outline,
                    ),
                  ),
                ),
                Icon(
                  Icons.edit_calendar_outlined,
                  size: 18,
                  color: _startDate != null
                      ? AppColors.primary
                      : AppColors.outline,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Jumlah Bulan ───────────────────────────────────────────────────
        Text(
          'Lama Sewa',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              // Tombol kurang
              _monthButton(
                icon: Icons.remove,
                onTap: _months > 1
                    ? () => setState(() => _months--)
                    : null,
              ),
              // Nilai bulan
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$_months',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      _months == 1 ? 'bulan' : 'bulan',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol tambah
              _monthButton(
                icon: Icons.add,
                onTap: _months < 24
                    ? () => setState(() => _months++)
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Info rentang tanggal otomatis ──────────────────────────────────
        if (_startDate != null && end != null)
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.date_range,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_displayDate(_startDate)}  →  ${_displayDate(end)}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _monthButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.onPrimary : AppColors.outline,
        ),
      ),
    );
  }

  // ── Creative Upload ──────────────────────────────────────────────────────────

  Widget _buildCreativeUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Creative Upload',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01 * 20,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload your ad creative. High-res PNG or JPG (Max 50MB).',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            // File picker – placeholder for real implementation
            setState(() => _uploadedFileName = 'ad_creative.png');
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: _uploadedFileName != null
                  ? AppColors.primaryFixed.withOpacity(0.15)
                  : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _uploadedFileName != null
                    ? AppColors.primary
                    : AppColors.outlineVariant,
                style: BorderStyle.solid,
                width: _uploadedFileName != null ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _uploadedFileName != null
                      ? Icons.check_circle_outline
                      : Icons.cloud_upload_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                if (_uploadedFileName != null) ...[
                  Text(
                    _uploadedFileName!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to change file',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Upload a file',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(
                          text: ' or drag and drop',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1080×1920px recommended',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Additional Notes ─────────────────────────────────────────────────────────

  Widget _buildAdditionalNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01 * 20,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 4,
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: 'Any specific instructions for the display?',
            hintStyle:
                GoogleFonts.inter(fontSize: 14, color: AppColors.outline),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.outlineVariant, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  // ── Price Summary ────────────────────────────────────────────────────────────

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _priceRow(
            label: 'Harga / Bulan',
            value: _formatMoney(_monthlyRate),
            isTotal: false,
          ),
          const SizedBox(height: 8),
          _priceRow(
            label: 'Durasi',
            value: '$_months Bulan',
            isTotal: false,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              color: AppColors.outlineVariant,
              height: 1,
              thickness: 0.4,
            ),
          ),
          _priceRow(
            label: 'Total',
            value: _startDate != null ? _formatMoney(_totalPrice) : '—',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _priceRow({
    required String label,
    required String value,
    required bool isTotal,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16 : 15,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal ? AppColors.onSurface : AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w700,
            letterSpacing: isTotal ? -0.02 * 20 : 0.01 * 16,
            color: isTotal ? AppColors.primary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  // ── Confirm Button ───────────────────────────────────────────────────────────

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitBooking,
        icon: _isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: AppColors.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.arrow_forward, size: 20),
        label: Text(
          _isSubmitting ? 'Processing...' : 'Confirm Booking',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01 * 16,
          ),
        ),
        iconAlignment: IconAlignment.end,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          disabledForegroundColor: AppColors.onPrimary.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          shadowColor: AppColors.primary.withOpacity(0.2),
        ),
      ),
    );
  }
}
