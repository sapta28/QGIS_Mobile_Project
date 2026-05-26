import 'dart:async';
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
import 'package:flutter_compass/flutter_compass.dart';

enum _MapStyle { osm, streets, satellite }

class _MapStyleConfig {
  final String label;
  final String urlTemplate;
  final ColorFilter? colorFilter;

  const _MapStyleConfig({
    required this.label,
    required this.urlTemplate,
    this.colorFilter,
  });
}

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final MapController _mapController = MapController();
  final ExploreController _controller = Get.find<ExploreController>();

  bool _isCompassMode = false;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  static const _mapStyles = <_MapStyle, _MapStyleConfig>{
    _MapStyle.osm: _MapStyleConfig(
      label: 'Standard OSM',
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    ),
    _MapStyle.streets: _MapStyleConfig(
      label: 'Streets',
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      colorFilter: ColorFilter.matrix([
        0.8, 0.1, 0.1, 0, 10,
        0.1, 0.8, 0.1, 0, 15,
        0.1, 0.1, 0.9, 0, 30,
        0, 0, 0, 1, 0,
      ]),
    ),
    _MapStyle.satellite: _MapStyleConfig(
      label: 'Satellite',
      urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    ),
  };

  BillboardModel? _selectedBillboard;
  Position? _userPosition;
  LatLng _initialCenter = const LatLng(-7.2575, 112.7529);
  bool _didFocusBillboards = false;
  _MapStyle _mapStyle = _MapStyle.osm;

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
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture && _selectedBillboard != null) {
                    setState(() {
                      _selectedBillboard = null;
                      });
                  }
                },
              ),
              children: [
                _buildTileLayer(),
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
          
          // Search Bar & Filter
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _SearchBar(),
            ),
          ),
          
          // Tombol My Location
          // Kelompok Tombol Kontrol Peta (Vertikal)
          Positioned(
            bottom: 25,
            right: 16,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Tombol Kompas (Otomatis muncul jika peta diputar)
                 // 1. Tombol Kompas / Rotasi Dinamis
                  StreamBuilder<MapEvent>(
                    stream: _mapController.mapEventStream,
                    builder: (context, snapshot) {
                      // Matikan mode kompas otomatis jika peta diputar manual oleh user
                      if (snapshot.hasData && snapshot.data!.source != MapEventSource.mapController) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_isCompassMode && mounted) {
                            setState(() => _isCompassMode = false);
                            _compassSubscription?.cancel(); // Hentikan sensor kompas
                          }
                        });
                      }

                      final rotation = _mapController.camera.rotation;
                      
                      IconData iconData;
                      Color iconColor;
                      double iconAngle = 0.0;

                      if (_isCompassMode) {
                        iconData = Icons.explore;
                        iconColor = AppColors.primary;
                      } else if (rotation == 0.0) {
                        iconData = Icons.navigation;
                        iconColor = AppColors.primary;
                      } else {
                        iconData = Icons.navigation;
                        iconColor = AppColors.outline;
                        iconAngle = -rotation * (3.141592653589793 / 180);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Transform.rotate(
                              angle: iconAngle,
                              child: Icon(
                                iconData,
                                color: iconColor,
                                size: 26,
                              ),
                            ),
                            onPressed: () async {
                              if (_isCompassMode) {
                                // Mematikan mode kompas
                                setState(() => _isCompassMode = false);
                                _compassSubscription?.cancel();
                                _mapController.rotate(0.0);
                              } else if (rotation == 0.0) {
                                // Mengaktifkan mode kompas
                                setState(() => _isCompassMode = true);
                                
                                // Mulai mendengarkan sensor kompas fisik
                                _compassSubscription = FlutterCompass.events?.listen((event) {
                                  if (_isCompassMode && event.heading != null) {
                                    // Putar peta secara terbalik (360 - heading) agar posisi jarum kompas UI sinkron
                                    _mapController.rotate(360 - event.heading!);
                                  }
                                });
                                
                                // Get.snackbar(
                                //   'Mode Kompas', 
                                //   'Peta sekarang mengikuti arah hadap HP Anda',
                                //   snackPosition: SnackPosition.TOP,
                                // );
                              } else {
                                // Reset ke arah Utara
                                _mapController.rotate(0.0);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // 2. Tombol Map Style (Layers)
                  CircleIconButton(
                    icon: Icons.layers_outlined,
                    onPressed: _openMapStyleSheet,
                    backgroundColor: Colors.white,
                    iconColor: AppColors.primary,
                    size: 48,
                  ),
                  
                  const SizedBox(height: 12), // Jarak antara Layers dan Lokasi
                  
                  // 3. Tombol My Location
                  CircleIconButton(
                    icon: Icons.my_location,
                    onPressed: _goToCurrentLocation,
                    backgroundColor: Colors.white,
                    iconColor: AppColors.primary,
                    size: 48,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TileLayer _buildTileLayer() {
    final config = _mapStyles[_mapStyle]!;
    return TileLayer(
      urlTemplate: config.urlTemplate,
      userAgentPackageName: 'com.billboardplatform.app',
      tileBuilder: config.colorFilter == null
          ? null
          : (context, widget, tile) =>
              ColorFiltered(colorFilter: config.colorFilter!, child: widget),
    );
  }

  void _openMapStyleSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Text(
                  'Map Style',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                ..._mapStyles.entries.map((entry) {
                  final isActive = entry.key == _mapStyle;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isActive ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isActive ? AppColors.primary : AppColors.outline,
                    ),
                    title: Text(
                      entry.value.label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    onTap: () {
                      setState(() => _mapStyle = entry.key);
                      Navigator.of(context).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Marker _buildMarker(BillboardModel billboard) {
    final isPremium = billboard.pricePerWeek >= 50000000;
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
          _mapController.move(LatLng(billboard.lat + 0.002, billboard.lng), 15.0);
          _mapController.rotate(0.0);
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
                      color: markerColor.withValues(alpha: 0.6),
                      blurRadius: 16,
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
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
    return Marker(
      point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
      // Lebar dibuat cukup besar (140) sebagai ruang batas panjang sinar radar
      width: 140, 
      height: 140,
      alignment: Alignment.center,
      rotate: false, // Marker induk dikunci, hanya sinar di dalamnya yang berputar
      child: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, compassSnapshot) {
          return StreamBuilder<MapEvent>(
            stream: _mapController.mapEventStream,
            builder: (context, mapSnapshot) {
              // 1. Dapatkan arah fisik HP (heading), default 0 jika sensor belum siap
              final heading = compassSnapshot.data?.heading ?? 0.0;
              
              // 2. Dapatkan rotasi peta saat ini
              final mapRotation = _mapController.camera.rotation;
              
              // 3. Kalkulasi arah sinar: Arah HP dikurangi rotasi kamera peta
              // (Agar sinar tidak melenceng kalau pengguna memutar peta pakai jari)
              final finalRotation = heading - mapRotation;

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Lapis Bawah: Sinar Radar yang berputar
                  Transform.rotate(
                    angle: finalRotation * (3.141592653589793 / 180),
                    child: CustomPaint(
                      size: const Size(140, 140),
                      painter: _RadarBeamPainter(color: AppColors.primary),
                    ),
                  ),
                  
                  // Lapis Atas: Titik Biru Pusat (Ukurannya diperkecil)
                  Container(
                    width: 18, // Ukuran titik diperkecil dari sebelumnya
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Marker _buildPopupMarker(BillboardModel billboard) {
    return Marker(
      point: LatLng(billboard.lat, billboard.lng),
      width: 400,
      height: 300,
      alignment: Alignment.topCenter,
      child: UnconstrainedBox(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: _PropertyPreviewCard(
                      billboard: billboard,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => BillboardDetailScreen(billboard: billboard)));
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: SizedBox(
                      width: 24,
                      height: 14,
                      child: Stack(
                        children: [
                          ClipPath(
                            clipper: _TriangleClipper(),
                            child: Container(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
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
            ],
          ),
        ),
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
    return Row(
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
          width: 48,
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
          child: IconButton(
            icon: const Icon(Icons.tune, color: AppColors.onSurfaceVariant, size: 20),
            onPressed: () {
              Get.snackbar('Filter', 'Filter belum tersedia.');
            },
          ),
        ),
      ],
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

  String _formatRupiah(double amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = billboard.pricePerWeek >= 50000000;
    final availabilityColor = billboard.isAvailable
        ? const Color(0xFF22C55E)
        : AppColors.outline;
    final availabilityBg = billboard.isAvailable
        ? const Color(0xFFE7F8EF)
        : AppColors.surfaceContainerHigh;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 96,
              height: 128,
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
                    height: 128,
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
                          color: AppColors.secondaryContainer.withValues(alpha: 0.9),
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
            const SizedBox(width: 12),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              billboard.name,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.bookmark_border,
                            size: 18,
                            color: AppColors.outline,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              billboard.location,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: availabilityBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: availabilityColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                billboard.isAvailable
                                    ? 'Available Now'
                                    : 'Booked',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: availabilityColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 1,
                        color: AppColors.outlineVariant,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _formatRupiah(billboard.pricePerWeek),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/ month',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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

class _RadarBeamPainter extends CustomPainter {
  final Color color;

  _RadarBeamPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Membuat efek gradien dari warna terang di tengah ke transparan di luar
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.6),
          color.withValues(alpha: 0.0), // Memudar di ujung
        ],
        stops: const [0.1, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2))
      ..style = PaintingStyle.fill;

    // Arah "Utara/Atas" di Flutter Canvas adalah -90 derajat.
    // Kita buat bukaan sinar sebesar 60 derajat (berpusat di arah atas).
    const startAngle = -120 * (3.141592653589793 / 180); 
    const sweepAngle = 60 * (3.141592653589793 / 180);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2),
      startAngle,
      sweepAngle,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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