import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme.dart';
import '../../../../models/models.dart';
import '../../../../widgets/common_widgets.dart';

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
          Navigator.of(context).pushNamed(
            '/booking-form',
            arguments: billboard,
          );
        },
      ),
    );
  }
}
