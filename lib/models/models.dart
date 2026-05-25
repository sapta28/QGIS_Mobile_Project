class BillboardModel {
  final String id;
  final String name;
  final String location;
  final String city;
  final String imageUrl;
  final String type; // 'Digital' | 'Static'
  final double pricePerWeek;
  final String size;
  final String traffic;
  final int dailyImpressions;
  final bool isAvailable;
  final String description;
  final String direction;
  final double lat;
  final double lng;

  const BillboardModel({
    required this.id,
    required this.name,
    required this.location,
    required this.city,
    required this.imageUrl,
    required this.type,
    required this.pricePerWeek,
    required this.size,
    required this.traffic,
    required this.dailyImpressions,
    required this.isAvailable,
    required this.description,
    required this.direction,
    required this.lat,
    required this.lng,
  });
}

class BookingModel {
  final String id;
  final String referenceId;
  final BillboardModel billboard;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active' | 'pending' | 'past'
  final int weeklyImpressions;
  final double totalPrice;
  final String? rawStatus;

  const BookingModel({
    required this.id,
    required this.referenceId,
    required this.billboard,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.weeklyImpressions,
    required this.totalPrice,
    this.rawStatus,
  });
}

class DummyData {
  static const List<BillboardModel> billboards = [
    BillboardModel(
      id: '1',
      name: 'Times Square Spectacular',
      location: 'Broadway & 7th Ave',
      city: 'New York, NY',
      imageUrl:
          'https://images.unsplash.com/photo-1546484396-fb3fc6f95f98?w=800&q=80',
      type: 'Digital',
      pricePerWeek: 8400,
      size: "14' × 48'",
      traffic: 'Very High',
      dailyImpressions: 1200000,
      isAvailable: true,
      description:
          'Premium digital placement in the heart of Times Square. This iconic LED display captures massive daily impressions from global tourist and commuter traffic. Ideal for brand launches and major campaigns with 8-second spot rotations.',
      direction: 'Facing South traffic',
      lat: 34.0520,
      lng: -118.2430,
    ),
    BillboardModel(
      id: '2',
      name: 'Sunset Blvd Digital Hub',
      location: '8400 Sunset Blvd',
      city: 'West Hollywood, CA',
      imageUrl:
          'https://images.unsplash.com/photo-1533929736458-ca588d08c8be?w=800&q=80',
      type: 'Digital',
      pricePerWeek: 3200,
      size: "14' × 48'",
      traffic: 'High',
      dailyImpressions: 320000,
      isAvailable: true,
      description:
          'Premium digital placement on the iconic Sunset Strip. This high-definition display captures massive daily impressions from slow-moving entertainment and tourism traffic. Ideal for brand launches, entertainment releases, and luxury lifestyle campaigns.',
      direction: 'Facing East traffic',
      lat: 34.0530,
      lng: -118.2450,
    ),
    BillboardModel(
      id: '3',
      name: 'Highway 101 Southbound',
      location: 'I-101 Mile Marker 42',
      city: 'Los Angeles, CA',
      imageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
      type: 'Static',
      pricePerWeek: 1800,
      size: "10.5' × 36'",
      traffic: 'High',
      dailyImpressions: 850000,
      isAvailable: true,
      description:
          'Strategic static billboard along the busiest highway in California. Perfect for sustained brand awareness campaigns targeting commuters and travelers heading into the Los Angeles metro area.',
      direction: 'Facing North traffic',
      lat: 34.0510,
      lng: -118.2420,
    ),
    BillboardModel(
      id: '4',
      name: 'Downtown Transit Network',
      location: 'Clark & Lake Station',
      city: 'Chicago, IL',
      imageUrl:
          'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800&q=80',
      type: 'Digital',
      pricePerWeek: 2400,
      size: "6' × 12'",
      traffic: 'Medium',
      dailyImpressions: 180000,
      isAvailable: false,
      description:
          'High-visibility transit shelter panels in downtown Chicago. Captures daily rush-hour commuters and weekend shoppers with prime visibility in the Loop district.',
      direction: 'Multi-directional',
      lat: 34.0540,
      lng: -118.2410,
    ),
    BillboardModel(
      id: '5',
      name: 'I-95 Northbound Digital',
      location: 'Downtown Sector A',
      city: 'Miami, FL',
      imageUrl:
          'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=800&q=80',
      type: 'Digital',
      pricePerWeek: 2900,
      size: "14' × 48'",
      traffic: 'High',
      dailyImpressions: 124500,
      isAvailable: true,
      description:
          'Prime digital billboard on I-95 capturing northbound traffic into Miami. Exceptional visibility in all weather conditions with a 24/7 illuminated display reaching commuters, tourists, and business travelers.',
      direction: 'Facing North traffic',
      lat: 34.0500,
      lng: -118.2460,
    ),
  ];

  static final List<BookingModel> activeBookings = [
    BookingModel(
      id: 'b1',
      referenceId: 'BKG-4521-AB',
      billboard: billboards[0],
      startDate: DateTime(2023, 10, 15),
      endDate: DateTime(2023, 11, 14),
      status: 'active',
      weeklyImpressions: 1200000,
      totalPrice: 33600,
    ),
    BookingModel(
      id: 'b2',
      referenceId: 'BKG-3312-CD',
      billboard: billboards[2],
      startDate: DateTime(2023, 11, 1),
      endDate: DateTime(2023, 12, 31),
      status: 'active',
      weeklyImpressions: 850000,
      totalPrice: 14400,
    ),
  ];

  static final List<BookingModel> pendingBookings = [
    BookingModel(
      id: 'b3',
      referenceId: 'BKG-7824-XV',
      billboard: billboards[3],
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 1, 31),
      status: 'pending',
      weeklyImpressions: 180000,
      totalPrice: 9600,
    ),
  ];

  static final List<BookingModel> pastBookings = [
    BookingModel(
      id: 'b4',
      referenceId: 'BKG-1102-ZX',
      billboard: billboards[1],
      startDate: DateTime(2023, 7, 1),
      endDate: DateTime(2023, 8, 31),
      status: 'past',
      weeklyImpressions: 320000,
      totalPrice: 25600,
    ),
  ];
}
