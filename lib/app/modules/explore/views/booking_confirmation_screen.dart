import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../home/controllers/home_controller.dart';
import '../../activity/controllers/activity_controller.dart';
import 'tripay_checkout_webview.dart';

class BookingConfirmationScreen extends StatefulWidget {
  /// Name of the billboard that was booked.
  final String billboardName;

  /// Start date string, e.g. "Nov 01, 2024".
  final String startDate;

  /// End date string, e.g. "Nov 14, 2024".
  final String endDate;

  /// Backend reference ID, e.g. "BKG-7824-XV".
  final String referenceId;

  /// Optional TriPay checkout URL returned by backend.
  final String? checkoutUrl;

  const BookingConfirmationScreen({
    super.key,
    required this.billboardName,
    required this.startDate,
    required this.endDate,
    required this.referenceId,
    this.checkoutUrl,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _checkoutOpened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openCheckoutIfAvailable();
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String get _campaignDates => '${widget.startDate} – ${widget.endDate}';

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, safeTop + 16, 20, safeBottom + 24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F0B1C30),
                    blurRadius: 40,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Check circle icon ─────────────────────────────────────
                  _buildCheckIcon(),
                  const SizedBox(height: 28),

                  // ── Headline ──────────────────────────────────────────────
                  Text(
                    widget.checkoutUrl != null && widget.checkoutUrl!.isNotEmpty
                        ? 'Pembayaran DP Siap'
                        : 'Booking Submitted!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.02 * 24,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.checkoutUrl != null && widget.checkoutUrl!.isNotEmpty
                        ? 'Booking berhasil dibuat. Lanjut bayar DP lewat Tripay, lalu kamu akan masuk ke status tracker.'
                        : 'Booking berhasil dibuat. Tim kami akan meninjau pesananmu.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Summary data card ─────────────────────────────────────
                  _buildSummaryCard(),
                  const SizedBox(height: 32),

                  // ── Booking workflow tracker ─────────────────────────────
                  _buildWorkflowCard(),
                  const SizedBox(height: 32),

                  // ── Action buttons ────────────────────────────────────────
                  _buildButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Check icon with glow ─────────────────────────────────────────────────────

  Widget _buildCheckIcon() {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle bg
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
          ),
          // Glow
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryFixed.withOpacity(0.5),
            ),
            width: 80,
            height: 80,
          ),
          // Icon
          const Icon(
            Icons.check_circle,
            size: 52,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // ── Summary card ──────────────────────────────────────────────────────────────

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Billboard row
          _summaryRow(
            label: 'Billboard',
            value: widget.billboardName,
            valueColor: AppColors.onSurface,
          ),
          _divider(),
          // Campaign dates row
          _summaryRow(
            label: 'Campaign Dates',
            value: _campaignDates,
            valueColor: AppColors.onSurface,
          ),
          _divider(),
          // Reference ID row
          _summaryRow(
            label: 'Reference ID',
            value: widget.referenceId,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.05 * 12,
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.01 * 17,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Divider(
        height: 1,
        thickness: 0.8,
        color: AppColors.outlineVariant.withOpacity(0.35),
      ),
    );
  }

  Widget _buildWorkflowCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Tracker',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pembayaran DP dilakukan lewat Tripay agar slot langsung terkunci setelah pembayaran berhasil.',
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.4,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _workflowRow(
            index: 1,
            title: 'Bayar DP',
            subtitle: 'Checkout Tripay dibuka untuk menyelesaikan pembayaran termin 1.',
            active: true,
          ),
          _workflowConnector(active: true),
          _workflowRow(
            index: 2,
            title: 'DP Lunas',
            subtitle: 'Slot reklame terkunci setelah pembayaran DP berhasil.',
            active: false,
          ),
          _workflowConnector(active: false),
          _workflowRow(
            index: 3,
            title: 'Menunggu Approval',
            subtitle: 'Admin meninjau desain dan memberi status approve / reject.',
            active: false,
          ),
          _workflowConnector(active: false),
          _workflowRow(
            index: 4,
            title: 'Menunggu Pelunasan',
            subtitle: 'Termin 2 terbit setelah desain disetujui.',
            active: false,
          ),
          _workflowConnector(active: false),
          _workflowRow(
            index: 5,
            title: 'Ready to Install',
            subtitle: 'Pekerjaan lapangan bisa dimulai setelah pelunasan.',
            active: false,
          ),
        ],
      ),
    );
  }

  Widget _workflowRow({
    required int index,
    required String title,
    required String subtitle,
    required bool active,
  }) {
    final color = active ? const Color(0xFF059669) : AppColors.outline;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE7F8EF) : AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Center(
            child: Text(
              '$index',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _workflowConnector({required bool active}) {
    return Padding(
      padding: const EdgeInsets.only(left: 13, top: 4, bottom: 4),
      child: Container(
        width: 2,
        height: 14,
        color: active ? const Color(0xFFB7E4C7) : AppColors.outlineVariant,
      ),
    );
  }

  // ── Buttons ───────────────────────────────────────────────────────────────────

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        if (widget.checkoutUrl != null && widget.checkoutUrl!.isNotEmpty) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                shadowColor: const Color(0xFF059669).withOpacity(0.25),
              ),
              child: Text(
                'Bayar Sekarang',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.01 * 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        // Primary: Go to My Bookings
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _goToBookingsTab();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              shadowColor: AppColors.primary.withOpacity(0.25),
            ),
            child: Text(
              'Go to My Bookings',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.01 * 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Secondary: Back to Map
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Get.until((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainer,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              'Back to Map',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.01 * 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openCheckout() async {
    final url = widget.checkoutUrl;
    if (url == null || url.isEmpty) {
      Get.snackbar('Payment', 'Link pembayaran belum tersedia.');
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      Get.snackbar('Payment', 'Link pembayaran tidak valid.');
      return;
    }

    final paid = await Get.to<bool>(
      () => TriPayCheckoutWebView(
        checkoutUrl: uri.toString(),
        title: 'TriPay Payment',
      ),
      fullscreenDialog: true,
    );

    if (paid == true && mounted) {
      _goToBookingsTab();
    }
  }

  Future<void> _openCheckoutIfAvailable() async {
    if (_checkoutOpened) return;
    final url = widget.checkoutUrl;
    if (url == null || url.isEmpty) return;

    _checkoutOpened = true;
    await _openCheckout();
  }

  void _goToBookingsTab() {
    Get.until((route) => route.isFirst);
    Get.find<HomeController>().changeNav(1);
    if (Get.isRegistered<ActivityController>()) {
      Get.find<ActivityController>().fetchActivities(status: null);
    }
  }
}
