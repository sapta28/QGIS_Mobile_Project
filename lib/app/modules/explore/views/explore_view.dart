import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({Key? key}) : super(key: key);

  @override
  _ExploreViewState createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final List<Marker> _markers = [];
  Map<String, dynamic>? _selectedLocation;

  static const Color _primary = Color(0xFF1E88E5);

  static const LatLng _initialCenter = LatLng(-7.2575, 112.7521);

  final List<Map<String, dynamic>> _adSpots = [
    {
      'id': '1',
      'position': const LatLng(-7.275, 112.750),
      'title': 'Videotron Jl. Basuki Rahmat',
      'available': true,
      'impressions': '124.5k Viewers / Hari',
      'price': 'Rp 15.000.000 / bln',
      'image': 'https://images.unsplash.com/photo-1542282088-fe8426682b8f?auto=format&fit=crop&w=400&q=80',
    },
    {
      'id': '2',
      'position': const LatLng(-7.250, 112.760),
      'title': 'Baliho Jl. Ahmad Yani',
      'available': false,
      'impressions': '98.2k Viewers / Hari',
      'price': 'Rp 8.500.000 / bln',
      'image': 'https://images.unsplash.com/photo-1620912196424-df3c8f8b80fc?auto=format&fit=crop&w=400&q=80',
    },
    {
      'id': '3',
      'position': const LatLng(-7.285, 112.740),
      'title': 'Signage Tunjungan Plaza',
      'available': true,
      'impressions': '250.1k Viewers / Hari',
      'price': 'Rp 22.000.000 / bln',
      'image': 'https://images.unsplash.com/photo-1486006920555-c77dcf18193c?auto=format&fit=crop&w=400&q=80',
    }
  ];

  @override
  void initState() {
    super.initState();
    _setMarkers();
  }

  void _setMarkers() {
    _markers
      ..clear()
      ..addAll(
        _adSpots.map(
          (spot) => Marker(
            point: spot['position'],
            width: 44,
            height: 44,
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedLocation = spot;
                });
              },
              child: Icon(
                Icons.location_on,
                color: spot['available'] ? const Color(0xFF6B4EFF) : const Color(0xFFFF3B30),
                size: 36,
              ),
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: _primary,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                color: _primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: const [
                    Text(
                      'Explore Lokasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                          child: Stack(
                            children: [
                              FlutterMap(
                                options: MapOptions(
                                  initialCenter: _initialCenter,
                                  initialZoom: 12,
                                  onTap: (_, __) {
                                    setState(() {
                                      _selectedLocation = null;
                                    });
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.flutter_application_1',
                                  ),
                                  MarkerLayer(markers: _markers),
                                ],
                              ),
                              _buildSearchBar(),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: FloatingActionButton(
                                  mini: true,
                                  backgroundColor: Colors.white,
                                  onPressed: () {},
                                  child: const Icon(Icons.my_location, color: _primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_selectedLocation != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 80),
                          child: _buildDetailsCard(),
                        )
                      else
                        const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 24,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 10),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari jalan atau area...',
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune, color: Color(0xFF4B5563), size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteIcons() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: _primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 16),
        ),
        Container(
          width: 2,
          height: 36,
          color: Colors.grey.shade300,
        ),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: _primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.visibility, color: Colors.white, size: 16),
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRouteIcons(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Titik Reklame',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedLocation!['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Estimasi Traffic',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedLocation!['impressions'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFFF3F4F6), thickness: 1.5),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(_selectedLocation!['image']),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PT Smart AdTech',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    Text(
                      'Verified Mitra',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone, color: _primary, size: 18),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.message, color: _primary, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Harga Sewa',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedLocation!['price'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _primary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedLocation!['available'] ? _primary : const Color(0xFF4B5563),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _selectedLocation!['available'] ? 'Tersedia' : 'Dipesan',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}