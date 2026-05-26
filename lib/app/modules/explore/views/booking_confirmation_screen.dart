import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../home/controllers/home_controller.dart';
import '../../activity/controllers/activity_controller.dart';

class BookingConfirmationScreen extends StatelessWidget {
  /// Name of the billboard that was booked.
  final String billboardName;

  /// Start date string, e.g. "Nov 01, 2024".
  final String startDate;

  /// End date string, e.g. "Nov 14, 2024".
  final String endDate;

  /// Backend reference ID, e.g. "BKG-7824-XV".
  final String referenceId;

  const BookingConfirmationScreen({
    super.key,
    required this.billboardName,
    required this.startDate,
    required this.endDate,
    required this.referenceId,
  });

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String get _campaignDates => '$startDate – $endDate';

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
                    'Booking Submitted!',
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
                    'Our team is reviewing your ad.\nYou\'ll be notified within 24 hours.',
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
            value: billboardName,
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
            value: referenceId,
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

  // ── Buttons ───────────────────────────────────────────────────────────────────

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        // Primary: Go to My Bookings
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to the Activity / My Bookings tab
              // Pop all screens to root, then switch to bookings tab
              Get.until((route) => route.isFirst);
              Get.find<HomeController>().changeNav(1);
              if (Get.isRegistered<ActivityController>()) {
                Get.find<ActivityController>().fetchActivities(status: null);
              }
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
              // Pop back to the map / explore screen
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
}
