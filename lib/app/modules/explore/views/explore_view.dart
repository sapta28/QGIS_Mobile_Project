import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Pastikan untuk menyesuaikan path import ini sesuai struktur folder di project GetX Anda
import '../../../../core/theme.dart';
import '../../../../models/models.dart';
import 'billboard_detail_screen.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final MapController _mapController = MapController();
  BillboardModel? _selectedBillboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: Stack(
        children: [
          // LEVEL 0: Map Background
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(34.0522, -118.2437),
              initialZoom: 15.0,
              onTap: (_, __) {
                setState(() {
                  _selectedBillboard = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.billboardplatform.app',
                tileBuilder: (context, widget, tile) {
                  // Mute the colors of the OSM tiles slightly to match design
                  return ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.8, 0.1, 0.1, 0, 10,
                      0.1, 0.8, 0.1, 0, 15,
                      0.1, 0.1, 0.9, 0, 30,
                      0, 0, 0, 1, 0,
                    ]),
                    child: widget,
                  );
                },
              ),
              MarkerLayer(
                markers: DummyData.billboards.map((b) => _buildMarker(b)).toList(),
              ),
            ],
          ),

          // LEVEL 1: Top Nav & Search (Floating)
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 16),
                _TopAppBar(),
                const SizedBox(height: 16),
                _SearchBar(),
              ],
            ),
          ),

          // LEVEL 2: Floating Property Preview Card
          if (_selectedBillboard != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _PropertyPreviewCard(
                billboard: _selectedBillboard!,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          BillboardDetailScreen(billboard: _selectedBillboard!),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Marker _buildMarker(BillboardModel billboard) {
    bool isPremium = billboard.pricePerWeek > 3000;
    bool isAvailable = billboard.isAvailable;

    Color markerColor;
    IconData iconData;
    double size;

    if (!isAvailable) {
      markerColor = AppColors.outline; // Muted Gray
      iconData = Icons.lock;
      size = 28;
    } else if (isPremium) {
      markerColor = AppColors.secondaryContainer; // Amber Glow
      iconData = Icons.visibility;
      size = 40;
    } else {
      markerColor = AppColors.primary; // Soft Blue
      iconData = Icons.campaign;
      size = 32;
    }

    return Marker(
      point: LatLng(billboard.lat, billboard.lng),
      width: size * 1.5,
      height: size * 1.5 + 10,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedBillboard = billboard;
          });
          _mapController.move(LatLng(billboard.lat, billboard.lng - 0.002), 15.0);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.surfaceContainerLowest, width: 3),
                boxShadow: [
                  if (isPremium)
                    BoxShadow(
                      color: markerColor.withOpacity(0.6),
                      blurRadius: 16,
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Icon(
                iconData,
                color: !isAvailable
                    ? AppColors.surfaceContainerLowest
                    : (isPremium
                        ? AppColors.onSecondaryContainer
                        : AppColors.onPrimary),
                size: size * 0.5,
              ),
            ),
            // Triangle pointer
            Transform.translate(
              offset: const Offset(0, -2),
              child: Container(
                width: 0,
                height: 0,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: size * 0.25, color: markerColor),
                    left: BorderSide(
                        width: size * 0.2, color: Colors.transparent),
                    right: BorderSide(
                        width: size * 0.2, color: Colors.transparent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () {},
          ),
          Text(
            'BillboardGo',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: AppColors.primary,
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(
                    'https://ui-avatars.com/api/?name=Alex+Mercer&background=003ec7&color=fff&size=128'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.surfaceContainerHigh),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.outline, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search locations, zones...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.outline,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primaryFixed),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.radar, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  '3KM RADIUS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.05 * 11,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyPreviewCard extends StatelessWidget {
  final BillboardModel billboard;
  final VoidCallback onTap;

  const _PropertyPreviewCard({
    required this.billboard,
    required this.onTap,
  });

  String _formatImpressions() {
    final val = billboard.dailyImpressions;
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}M';
    if (val >= 1000) return '${(val / 1000).round()}k';
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    bool isPremium = billboard.pricePerWeek > 3000;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: AppColors.primary.withOpacity(0.1), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image with Premium Badge
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: billboard.imageUrl,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.surfaceContainerHigh),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surfaceContainerHigh,
                      child: const Icon(Icons.image, color: AppColors.outline),
                    ),
                  ),
                  if (isPremium)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                size: 10, color: AppColors.onSecondaryContainer),
                            const SizedBox(width: 2),
                            Text(
                              'PREMIUM',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                billboard.name,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.bookmark_border,
                                size: 20, color: AppColors.outline),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                billboard.location,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EST. DAILY IMPR.',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.outline,
                              ),
                            ),
                            Text(
                              _formatImpressions(),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'AVAILABILITY',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.outline,
                              ),
                            ),
                            Text(
                              billboard.isAvailable
                                  ? 'Available Now'
                                  : 'Booked',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: billboard.isAvailable
                                    ? AppColors.secondary
                                    : AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
