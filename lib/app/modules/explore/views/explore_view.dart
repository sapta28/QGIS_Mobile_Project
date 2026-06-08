import 'dart:async';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../../../core/theme.dart';
import '../../../../models/models.dart';
import '../../../../widgets/common_widgets.dart';
import '../bindings/explore_binding.dart';
import '../controllers/explore_controller.dart';
import 'billboard_detail_screen.dart';

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
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  bool _isCompassMode = false;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _sheetController.dispose();
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

    // Auto-fokus peta dan buka panel saat filteredBillboards berubah
    // (dipicu oleh perubahan search, filter kategori, atau data baru dari API)
    ever(_controller.filteredBillboards, (List<BillboardModel> filtered) {
      if (!mounted) return;
      if (filtered.isNotEmpty && _controller.selectedCategory.value != null) {
        _focusOnBillboards(filtered);
        if (_sheetController.isAttached) {
          _sheetController.animateTo(
            0.6,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      }
    });
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
            if (_controller.filteredBillboards.isNotEmpty && !_didFocusBillboards) {
              _didFocusBillboards = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || _controller.filteredBillboards.isEmpty) {
                  return;
                }
                _focusOnBillboards(_controller.filteredBillboards);
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
                    ..._controller.filteredBillboards.map(_buildMarker),
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
            bottom: 100,
            right: 16,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<MapEvent>(
                    stream: _mapController.mapEventStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.source != MapEventSource.mapController) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_isCompassMode && mounted) {
                            setState(() => _isCompassMode = false);
                            _compassSubscription?.cancel();
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
                                setState(() => _isCompassMode = false);
                                _compassSubscription?.cancel();
                                _mapController.rotate(0.0);
                              } else if (rotation == 0.0) {
                                setState(() => _isCompassMode = true);
                                _compassSubscription = FlutterCompass.events?.listen((event) {
                                  if (_isCompassMode && event.heading != null) {
                                    _mapController.rotate(360 - event.heading!);
                                  }
                                });
                              } else {
                                _mapController.rotate(0.0);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  CircleIconButton(
                    icon: Icons.layers_outlined,
                    onPressed: _openMapStyleSheet,
                    backgroundColor: Colors.white,
                    iconColor: AppColors.primary,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
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
          // --- SLIDE-UP PANEL: DAFTAR BILLBOARD SEKITAR ---
          // Tidak ada lagi Padding pembungkus horizontal, sehingga full kiri-kanan
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.20,
            minChildSize: 0.20,
            maxChildSize: 0.85,
            snap: true,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Obx(() {
                  List<Map<String, dynamic>> sortedBillboards = [];

                  if (_userPosition != null) {
                    for (var b in _controller.filteredBillboards) {
                      double dist = Geolocator.distanceBetween(
                        _userPosition!.latitude, _userPosition!.longitude,
                        b.lat, b.lng,
                      );
                      sortedBillboards.add({'billboard': b, 'distance': dist});
                    }
                    sortedBillboards.sort((a, b) =>
                        (a['distance'] as double).compareTo(b['distance'] as double));
                  } else {
                    for (var b in _controller.filteredBillboards) {
                      sortedBillboards.add({'billboard': b, 'distance': null});
                    }
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF059669),
                    onRefresh: () => _controller.fetchSpots(),
                    child: ListView.builder(
                    controller: scrollController,
                    // Padding bottom dibuat 120 agar item paling bawah tidak tertutup Navbar
                    padding: const EdgeInsets.only(top: 0, bottom: 120),
                    itemCount: _controller.filteredBillboards.isEmpty ? 2 : sortedBillboards.length + 1,
                    itemBuilder: (context, index) {
                      
                      // --- HEADER DRAG HANDLE ---
                      if (index == 0) {
                        final hasFilter = _controller.selectedCategory.value != null;
                        final hasSearch = _controller.searchQuery.value.isNotEmpty;
                        final count = sortedBillboards.length;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(top: 12, bottom: 4),
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppColors.outlineVariant,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.explore, color: Colors.black, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          hasFilter || hasSearch
                                              ? 'Hasil Pencarian'
                                              : 'Di Sekitar Anda',
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black,
                                          ),
                                        ),
                                        if (_controller.filteredBillboards.isNotEmpty)
                                          Text(
                                            '$count billboard ditemukan',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: AppColors.outline,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Badge filter aktif
                                  if (hasFilter)
                                    GestureDetector(
                                      onTap: _controller.clearCategoryFilter,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _controller.selectedCategory.value!,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.close, size: 14, color: AppColors.primary),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 8),
                          ],
                        );
                      }

                      // --- STATE LOADING ---
                      if (_controller.filteredBillboards.isEmpty && _controller.isLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (_controller.filteredBillboards.isEmpty) {
                        final hasFilter = _controller.selectedCategory.value != null;
                        final hasSearch = _controller.searchQuery.value.isNotEmpty;
                        return Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  hasSearch ? Icons.search_off : Icons.location_off,
                                  color: AppColors.outline,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  hasSearch
                                      ? 'Tidak ada hasil untuk "${_controller.searchQuery.value}"'
                                      : hasFilter
                                          ? 'Tidak ada "${_controller.selectedCategory.value}" di area ini'
                                          : 'Tidak ada data billboard',
                                  style: GoogleFonts.inter(
                                    color: AppColors.outline,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (hasFilter || hasSearch)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: TextButton(
                                      onPressed: () {
                                        _controller.clearCategoryFilter();
                                        _controller.clearSearch();
                                      },
                                      child: Text(
                                        'Hapus filter & pencarian',
                                        style: GoogleFonts.inter(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }


                      // --- LIST ITEM ---
                      final item = sortedBillboards[index - 1];
                      final billboard = item['billboard'] as BillboardModel;
                      final distance = item['distance'] as double?;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _PropertyPreviewCard(
                            billboard: billboard,
                            distance: distance,
                            onTap: () {
                              // 1. Fokuskan peta ke billboard
                              setState(() => _selectedBillboard = billboard);
                              _mapController.move(LatLng(billboard.lat + 0.001, billboard.lng), 15.0);
                              
                              // 2. TUTUP SLIDE-UP PANEL SECARA OTOMATIS
                              if (_sheetController.isAttached) {
                                _sheetController.animateTo(
                                  0.18, // Kembali ke ukuran awal
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                );
                              }

                              // 3. KEMBALIKAN ISI LIST KE PALING ATAS (TITIK 0)
                              if (scrollController.hasClients) {
                                scrollController.animateTo(
                                  0.0, 
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                );
                              }
                            },
                          ),
                      );
                    },
                  ),
                  );
                }),
              );
            },
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
    return Marker(
      point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
      width: 140,
      height: 140,
      alignment: Alignment.center,
      rotate: false,
      child: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, compassSnapshot) {
          return StreamBuilder<MapEvent>(
            stream: _mapController.mapEventStream,
            builder: (context, mapSnapshot) {
              final heading = compassSnapshot.data?.heading ?? 0.0;
              final mapRotation = _mapController.camera.rotation;
              final finalRotation = heading - mapRotation;

              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: finalRotation * (3.141592653589793 / 180),
                    child: CustomPaint(
                      size: const Size(140, 140),
                      painter: _RadarBeamPainter(color: AppColors.primary),
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
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
      width: 280,
      height: 200,
      alignment: Alignment.topCenter,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: 280,
          maxHeight: 200,
          alignment: Alignment.topCenter,
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
                        borderRadius: BorderRadius.circular(20),
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
                    Positioned(
                      bottom: 0,
                      child: SizedBox(
                        width: 24,
                        height: 14,
                        child: Stack(
                          children: [
                            ClipPath(
                              clipper: _TriangleClipper(),
                              child: Container(color: AppColors.primary.withOpacity(0.3)),
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

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _controller = Get.find<ExploreController>();
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sync jika ada nilai awal
    _textController.text = _controller.searchQuery.value;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    final categories = [
      'Billboard',
      'Videotron',
      'LED',
      'Neon Box',
      'Bando',
      'Megatron',
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    Text(
                      'Filter Billboard',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pilih jenis media yang ingin ditampilkan',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Jenis Media',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      final selected = _controller.selectedCategory.value;
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.map((cat) {
                          final isActive = selected == cat;
                          return GestureDetector(
                            onTap: () {
                              if (isActive) {
                                _controller.clearCategoryFilter();
                              } else {
                                _controller.setCategoryFilter(cat);
                              }
                              setModalState(() {});
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFF059669) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isActive ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isActive) ...[  
                                    const Icon(Icons.check_circle, color: Colors.white, size: 16),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    cat,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isActive ? Colors.white : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _controller.clearCategoryFilter();
                              Navigator.pop(ctx);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              'Reset Filter',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: Text(
                              'Terapkan',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

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
                    controller: _textController,
                    onChanged: (val) => _controller.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Cari lokasi, zona, jenis...',
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
                Obx(() => _controller.searchQuery.value.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _textController.clear();
                        _controller.clearSearch();
                      },
                      child: const Icon(Icons.close, color: AppColors.outline, size: 18),
                    )
                  : const SizedBox.shrink()
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Obx(() {
          final hasFilter = _controller.selectedCategory.value != null;
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hasFilter ? const Color(0xFF059669) : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: hasFilter ? const Color(0xFF059669) : AppColors.surfaceContainerHigh,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune,
                color: hasFilter ? Colors.white : AppColors.onSurfaceVariant,
                size: 20,
              ),
              onPressed: _showFilterSheet,
            ),
          );
        }),
      ],
    );
  }
}

class _PropertyPreviewCard extends StatelessWidget {
  final BillboardModel billboard;
  final VoidCallback onTap;
  final double? distance;

  const _PropertyPreviewCard({
    required this.billboard,
    required this.onTap,
    this.distance,
  });

  String _formatRupiah(double amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
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
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
            const SizedBox(width: 12),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
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
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            distance != null
                                ? '${billboard.location} • ${_formatDistance(distance!)}'.trim()
                                : billboard.location,
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
                    Container(
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
                    const SizedBox(height: 10),
                    Container(
                      height: 1,
                      color: AppColors.outlineVariant,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _formatRupiah(billboard.pricePerWeek),
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ bln',
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
    
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.6),
          color.withOpacity(0.0), 
        ],
        stops: const [0.1, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2))
      ..style = PaintingStyle.fill;

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