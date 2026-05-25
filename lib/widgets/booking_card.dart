import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onTap;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
  });

  Widget _buildStatusBadge() {
    if (booking.rawStatus == 'pending_cancel') {
      return const StatusBadge(
        label: 'Waiting Cancel',
        backgroundColor: Color(0xFFFFF4EC), // Soft orange container
        textColor: Color(0xFFFF9500),       // Vivid orange text
        icon: Icons.cancel_outlined,
      );
    }
    if (booking.rawStatus == 'cancelled') {
      return const StatusBadge(
        label: 'Canceled',
        backgroundColor: Color(0xFFFFECEB), // Soft red container
        textColor: Color(0xFFFF3B30),       // Vivid red text
        icon: Icons.cancel_outlined,
      );
    }
    if (booking.rawStatus == 'rejected') {
      return const StatusBadge(
        label: 'Rejected',
        backgroundColor: Color(0xFFFFECEB), // Soft red container
        textColor: Color(0xFFFF3B30),       // Vivid red text
        icon: Icons.cancel_outlined,
      );
    }

    switch (booking.status) {
      case 'active':
        return StatusBadge(
          label: 'Active',
          backgroundColor: AppColors.surfaceContainerHigh,
          textColor: AppColors.primary,
          showPulse: true,
        );
      case 'pending':
        return StatusBadge(
          label: 'In Review',
          backgroundColor: AppColors.secondaryContainer,
          textColor: AppColors.onSecondaryContainer,
          icon: Icons.pending_actions,
        );
      case 'past':
        return StatusBadge(
          label: 'Completed',
          backgroundColor: AppColors.surfaceContainerHigh,
          textColor: AppColors.outline,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatDateRange() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final start = '${months[booking.startDate.month - 1]} ${booking.startDate.day}';
    final end = '${months[booking.endDate.month - 1]} ${booking.endDate.day}, ${booking.endDate.year}';
    return '$start - $end';
  }

  String _formatImpressions() {
    final val = booking.weeklyImpressions;
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}M';
    if (val >= 1000) return '${(val / 1000).round()}K';
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isPending = booking.status == 'pending';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isPending
              ? AppColors.surface.withOpacity(0.6)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPending
                ? AppColors.outlineVariant.withOpacity(0.5)
                : Colors.transparent,
          ),
          boxShadow: isPending
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Stack(
                children: [
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: booking.billboard.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceContainerHigh,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(Icons.image, color: AppColors.outline),
                      ),
                    ),
                  ),
                  // Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            booking.billboard.type == 'Digital'
                                ? Icons.bolt
                                : Icons.panorama,
                            size: 12,
                            color: booking.billboard.type == 'Digital'
                                ? AppColors.primary
                                : AppColors.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.billboard.type,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.05 * 11,
                              color: booking.billboard.type == 'Digital'
                                  ? AppColors.primary
                                  : AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.billboard.name,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.01 * 18,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    booking.billboard.city,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.outlineVariant, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.status == 'pending'
                                    ? 'REQUESTED DATES'
                                    : 'CAMPAIGN DATES',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.05 * 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDateRange(),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (booking.status != 'pending')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'EST. IMPRESSIONS',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.05 * 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: _formatImpressions(),
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.01 * 18,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' /wk',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'STATUS',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.05 * 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                booking.rawStatus == 'pending_cancel'
                                    ? 'Awaiting Cancellation'
                                    : 'Awaiting Approval',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
