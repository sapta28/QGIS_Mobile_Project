import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme.dart';
import '../../../../models/models.dart';
import '../../../../widgets/common_widgets.dart';
import '../bindings/explore_binding.dart';
import '../controllers/explore_controller.dart';
import 'billboard_detail_screen.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final MapController _mapController = MapController();
  final ExploreController _controller = Get.find<ExploreController>();

  BillboardModel? _selectedBillboard;
  Position? _userPosition;
  LatLng _initialCenter = const LatLng(-7.2575, 112.7529);
  bool _didFocusBillboards = false;

  @override
  void initState() {
    super.initState();
    _ensureDependencies();
    _initLocation();
  }

  void _ensureDependencies() {
    if (!Get.isRegistered<ExploreController>()) {
      ExploreBinding().dependencies();
    }
  }

  Future<void> _initLocation() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last == null) {
        return;
      }

      setState(() {
        _userPosition = last;
        _initialCenter = LatLng(last.latitude, last.longitude);
      });

      _controller.fetchSpots(lat: last.latitude, lng: last.longitude);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _mapController.move(LatLng(last.latitude, last.longitude), 13.0);
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: Stack(
        children: [
          Obx(() {
            if (_controller.billboards.isNotEmpty && !_didFocusBillboards) {
              _didFocusBillboards = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || _controller.billboards.isEmpty) {
                  return;
                }
                _focusOnBillboards(_controller.billboards);
              });
            }

            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialCenter,
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
                  markers: [
                    ..._controller.billboards.map(_buildMarker),
                    if (_userPosition != null) _buildUserMarker(),
                    if (_selectedBillboard != null) _buildPopupMarker(_selectedBillboard!),
                  ],
                ),
              ],
            );
          }),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _SearchBar(),
            ),
          ),
          Positioned(
            bottom: 25,
            right: 16,
            child: SafeArea(
              child: CircleIconButton(
                icon: Icons.my_location,
                onPressed: _goToCurrentLocation,
                backgroundColor: Colors.white,
                iconColor: AppColors.primary,
                size: 48,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(BillboardModel billboard) {
    final isPremium = billboard.pricePerWeek > 3000;
    final isAvailable = billboard.isAvailable;

    Color markerColor;
    IconData iconData;
    double size;

    if (!isAvailable) {
      markerColor = AppColors.outline;
      iconData = Icons.lock;
      size = 28;
    } else if (isPremium) {
      markerColor = AppColors.secondaryContainer;
      iconData = Icons.visibility;
      size = 40;
    } else {
      markerColor = AppColors.primary;
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
          _mapController.move(LatLng(billboard.lat - 0.002, billboard.lng), 15.0);
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
                  color: AppColors.surfaceContainerLowest,
                  width: 3,
                ),
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
            Transform.translate(
              offset: const Offset(0, -2),
              child: Container(
                width: 0,
                height: 0,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: size * 0.25, color: markerColor),
                    left: BorderSide(
                      width: size * 0.2,
                      color: Colors.transparent,
                    ),
                    right: BorderSide(
                      width: size * 0.2,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Marker _buildUserMarker() {
    final pos = _userPosition!;
    return Marker(
      point: LatLng(pos.latitude, pos.longitude),
      width: 40,
      height: 40,
      alignment: Alignment.center,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.28),
              blurRadius: 12,
            ),
          ],
        ),
        child: const Icon(Icons.person_pin_circle, color: Colors.white, size: 22),
      ),
    );
  }

 Marker _buildPopupMarker(BillboardModel billboard) {
    return Marker(
      point: LatLng(billboard.lat, billboard.lng),
      width: 360,
      height: 200,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: _PropertyPreviewCard(
                  billboard: billboard,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => BillboardDetailScreen(billboard: billboard)));
                  },
                ),
              ),
              // Segitiga dengan stroke yang menyambung
              Positioned(
                bottom: 0,
                child: SizedBox(
                  width: 24,
                  height: 14,
                  child: Stack(
                    children: [
                      // Segitiga Stroke (sedikit lebih besar)
                      ClipPath(
                        clipper: _TriangleClipper(),
                        child: Container(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      // Segitiga Isi (sedikit lebih kecil untuk menutupi bagian tengah)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1.5),
                        child: ClipPath(
                          clipper: _TriangleClipper(),
                          child: Container(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 55),
        ],
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar('Lokasi', 'Izin lokasi ditolak');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _userPosition = pos;
      });
      _mapController.move(LatLng(pos.latitude, pos.longitude), 15.0);
    } catch (e) {
      Get.snackbar('Lokasi', 'Gagal mengambil lokasi: $e');
    }
  }

  void _focusOnBillboards(List<BillboardModel> billboards) {
    if (billboards.isEmpty) {
      return;
    }

    final avgLat = billboards.map((b) => b.lat).reduce((a, b) => a + b) /
        billboards.length;
    final avgLng = billboards.map((b) => b.lng).reduce((a, b) => a + b) /
        billboards.length;

    try {
      _mapController.move(LatLng(avgLat, avgLng), 12.5);
    } catch (_) {}
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    final isPremium = billboard.pricePerWeek > 3000;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
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
                    imageUrl: billboard.imageUrl.isNotEmpty
                        ? billboard.imageUrl
                        : 'https://images.unsplash.com/photo-1546484396-fb3fc6f95f98?w=800&q=80',
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
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 10,
                              color: AppColors.onSecondaryContainer,
                            ),
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
                            const Icon(
                              Icons.bookmark_border,
                              size: 20,
                              color: AppColors.outline,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
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
                              billboard.isAvailable ? 'Available Now' : 'Booked',
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

class _TriangleClipper extends CustomClipper<ui.Path> {
  @override
  ui.Path getClip(ui.Size size) {
    final path = ui.Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<ui.Path> oldClipper) => false;
}