import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

// ─── Models ───────────────────────────────────────────────

class PaymentMethodModel {
  final String id;
  final String type; // 'credit_card' | 'bank' | 'wallet'
  final String brand; // 'Visa' | 'Mastercard' | 'BCA' | 'GoPay' | ...
  final String lastFour;
  final String expiry;
  bool isDefault;

  PaymentMethodModel({
    required this.id,
    required this.type,
    required this.brand,
    required this.lastFour,
    required this.expiry,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'brand': brand,
        'lastFour': lastFour,
        'expiry': expiry,
        'isDefault': isDefault,
      };

  factory PaymentMethodModel.fromJson(Map<String, dynamic> j) =>
      PaymentMethodModel(
        id: j['id'] as String,
        type: j['type'] as String,
        brand: j['brand'] as String,
        lastFour: j['lastFour'] as String,
        expiry: j['expiry'] as String,
        isDefault: j['isDefault'] as bool? ?? false,
      );
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String category; // 'booking' | 'payment' | 'promo' | 'system'
  bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'category': category,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };

  factory NotificationModel.fromJson(Map<String, dynamic> j) =>
      NotificationModel(
        id: j['id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        category: j['category'] as String,
        isRead: j['isRead'] as bool? ?? false,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

class SavedBillboardModel {
  final String id;
  final String spotId;
  final String name;
  final String location;
  final String city;
  final String imageUrl;
  final String type;
  final double pricePerMonth;
  final DateTime savedAt;

  const SavedBillboardModel({
    required this.id,
    required this.spotId,
    required this.name,
    required this.location,
    required this.city,
    required this.imageUrl,
    required this.type,
    required this.pricePerMonth,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'spotId': spotId,
        'name': name,
        'location': location,
        'city': city,
        'imageUrl': imageUrl,
        'type': type,
        'pricePerMonth': pricePerMonth,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedBillboardModel.fromJson(Map<String, dynamic> j) =>
      SavedBillboardModel(
        id: j['id'] as String,
        spotId: j['spotId'] as String,
        name: j['name'] as String,
        location: j['location'] as String,
        city: j['city'] as String,
        imageUrl: j['imageUrl'] as String,
        type: j['type'] as String,
        pricePerMonth: (j['pricePerMonth'] as num).toDouble(),
        savedAt: DateTime.parse(j['savedAt'] as String),
      );
}

class CampaignHistoryModel {
  final String id;
  final String referenceId;
  final String campaignName;
  final String location;
  final String city;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'past' | 'expired' | 'cancelled'
  final double totalAmount;

  const CampaignHistoryModel({
    required this.id,
    required this.referenceId,
    required this.campaignName,
    required this.location,
    required this.city,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalAmount,
  });
}

class FaqModel {
  final String id;
  final String category; // 'Booking' | 'Pembayaran' | 'Materi Iklan' | 'Akun'
  final String question;
  final String answer;
  final List<String> infoItems; // Bullet points tambahan
  final String? actionLabel;   // Label tombol aksi
  final VoidCallback? actionRoute; // Navigasi saat tombol diklik

  const FaqModel({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    this.infoItems = const [],
    this.actionLabel,
    this.actionRoute,
  });
}

// ─── Mock Service ──────────────────────────────────────────

class ProfileMockService {
  static const _pmKey = 'mock_payment_methods';
  static const _notifKey = 'mock_notifications';
  static const _favKey = 'mock_saved_billboards';

  final _box = GetStorage();

  // ─── PAYMENT METHODS ───────────────────────────────────

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final raw = _box.read<List>(_pmKey);
    if (raw != null) {
      return raw
          .map((e) => PaymentMethodModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    // Seed defaults
    final defaults = _defaultPaymentMethods();
    _savePaymentMethods(defaults);
    return defaults;
  }

  Future<void> addPaymentMethod(PaymentMethodModel method) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = await getPaymentMethods();
    list.add(method);
    _savePaymentMethods(list);
  }

  Future<void> deletePaymentMethod(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = await getPaymentMethods();
    list.removeWhere((m) => m.id == id);
    _savePaymentMethods(list);
  }

  Future<void> setDefaultPaymentMethod(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = await getPaymentMethods();
    for (final m in list) {
      m.isDefault = m.id == id;
    }
    _savePaymentMethods(list);
  }

  void _savePaymentMethods(List<PaymentMethodModel> list) {
    _box.write(_pmKey, list.map((e) => e.toJson()).toList());
  }

  List<PaymentMethodModel> _defaultPaymentMethods() => [
        PaymentMethodModel(
          id: 'pm_1',
          type: 'credit_card',
          brand: 'Visa',
          lastFour: '4242',
          expiry: '12/26',
          isDefault: true,
        ),
        PaymentMethodModel(
          id: 'pm_2',
          type: 'credit_card',
          brand: 'Mastercard',
          lastFour: '8812',
          expiry: '09/25',
          isDefault: false,
        ),
        PaymentMethodModel(
          id: 'pm_3',
          type: 'wallet',
          brand: 'GoPay',
          lastFour: '',
          expiry: '',
          isDefault: false,
        ),
      ];

  // ─── NOTIFICATIONS ─────────────────────────────────────

  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final raw = _box.read<List>(_notifKey);
    if (raw != null) {
      return raw
          .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    final defaults = _defaultNotifications();
    _saveNotifications(defaults);
    return defaults;
  }

  Future<void> markNotificationRead(String id) async {
    final list = await getNotifications();
    for (final n in list) {
      if (n.id == id) n.isRead = true;
    }
    _saveNotifications(list);
  }

  Future<void> markAllNotificationsRead() async {
    final list = await getNotifications();
    for (final n in list) {
      n.isRead = true;
    }
    _saveNotifications(list);
  }

  void _saveNotifications(List<NotificationModel> list) {
    _box.write(_notifKey, list.map((e) => e.toJson()).toList());
  }

  List<NotificationModel> _defaultNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'n1',
        title: 'Booking Dikonfirmasi',
        body: 'Booking billboard "Bundaran HI – Digital Screen A" Anda telah dikonfirmasi untuk periode 1–31 Juli 2025.',
        category: 'booking',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: 'n2',
        title: 'Pembayaran Berhasil',
        body: 'Pembayaran sebesar Rp 12.500.000 untuk booking BKG-4521-AB telah berhasil diproses.',
        category: 'payment',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      NotificationModel(
        id: 'n3',
        title: 'Promo Spesial Akhir Bulan!',
        body: 'Dapatkan diskon 15% untuk booking billboard di area Jakarta Pusat selama Juni 2025. Gunakan kode JUNI15.',
        category: 'promo',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      NotificationModel(
        id: 'n4',
        title: 'Booking Akan Berakhir',
        body: 'Booking billboard "Thamrin City – Fasad Utara" Anda akan berakhir dalam 3 hari. Perpanjang sekarang.',
        category: 'booking',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: 'n5',
        title: 'Pembaruan Sistem',
        body: 'Kami telah memperbarui fitur peta interaktif. Kini Anda dapat melihat ketersediaan billboard secara real-time.',
        category: 'system',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      NotificationModel(
        id: 'n6',
        title: 'Invoice Tersedia',
        body: 'Invoice #INV-2025-0612 untuk booking BKG-3312-CD telah diterbitkan. Klik untuk mengunduh.',
        category: 'payment',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      NotificationModel(
        id: 'n7',
        title: 'Flash Sale Billboard Premium',
        body: 'Hanya hari ini! Billboard premium Sudirman – Grade A tersedia dengan harga spesial. Segera amankan slot Anda.',
        category: 'promo',
        isRead: false,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      NotificationModel(
        id: 'n8',
        title: 'Akun Terverifikasi',
        body: 'Selamat! Akun bisnis Anda telah berhasil diverifikasi. Kini Anda dapat mengakses semua fitur premium.',
        category: 'system',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }

  // ─── SAVED BILLBOARDS ──────────────────────────────────

  Future<List<SavedBillboardModel>> getSavedBillboards() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final raw = _box.read<List>(_favKey);
    if (raw != null) {
      return raw
          .map((e) => SavedBillboardModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    final defaults = _defaultSavedBillboards();
    _saveFavorites(defaults);
    return defaults;
  }

  Future<void> removeSavedBillboard(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = await getSavedBillboards();
    list.removeWhere((b) => b.id == id);
    _saveFavorites(list);
  }

  void _saveFavorites(List<SavedBillboardModel> list) {
    _box.write(_favKey, list.map((e) => e.toJson()).toList());
  }

  List<SavedBillboardModel> _defaultSavedBillboards() {
    final now = DateTime.now();
    return [
      SavedBillboardModel(
        id: 'fav_1',
        spotId: 'spot_101',
        name: 'Bundaran HI – Digital Screen A',
        location: 'Jl. MH Thamrin No.1',
        city: 'Jakarta Pusat',
        imageUrl: 'https://images.unsplash.com/photo-1546484396-fb3fc6f95f98?w=800&q=80',
        type: 'Digital',
        pricePerMonth: 45000000,
        savedAt: now.subtract(const Duration(days: 2)),
      ),
      SavedBillboardModel(
        id: 'fav_2',
        spotId: 'spot_102',
        name: 'Sudirman Business Park – Tower A',
        location: 'Jl. Jend. Sudirman Kav. 52',
        city: 'Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1533929736458-ca588d08c8be?w=800&q=80',
        type: 'Static',
        pricePerMonth: 28000000,
        savedAt: now.subtract(const Duration(days: 5)),
      ),
      SavedBillboardModel(
        id: 'fav_3',
        spotId: 'spot_103',
        name: 'Gatot Subroto – Flyover Selatan',
        location: 'Jl. Gatot Subroto KM 3',
        city: 'Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
        type: 'Digital',
        pricePerMonth: 32000000,
        savedAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }

  // ─── CAMPAIGN HISTORY ──────────────────────────────────

  Future<List<CampaignHistoryModel>> getCampaignHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _defaultCampaignHistory();
  }

  List<CampaignHistoryModel> _defaultCampaignHistory() {
    return [
      CampaignHistoryModel(
        id: 'ch_1',
        referenceId: 'BKG-4521-AB',
        campaignName: 'Campaign Peluncuran Produk Q2',
        location: 'Bundaran HI – Digital Screen A',
        city: 'Jakarta Pusat',
        imageUrl: 'https://images.unsplash.com/photo-1546484396-fb3fc6f95f98?w=800&q=80',
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 3, 31),
        status: 'past',
        totalAmount: 135000000,
      ),
      CampaignHistoryModel(
        id: 'ch_2',
        referenceId: 'BKG-3312-CD',
        campaignName: 'Brand Awareness – Semester 1',
        location: 'Sudirman Business Park – Tower A',
        city: 'Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1533929736458-ca588d08c8be?w=800&q=80',
        startDate: DateTime(2024, 7, 1),
        endDate: DateTime(2024, 12, 31),
        status: 'past',
        totalAmount: 168000000,
      ),
      CampaignHistoryModel(
        id: 'ch_3',
        referenceId: 'BKG-7824-XV',
        campaignName: 'Promo Akhir Tahun 2024',
        location: 'Gatot Subroto – Flyover Selatan',
        city: 'Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
        startDate: DateTime(2024, 11, 1),
        endDate: DateTime(2024, 12, 31),
        status: 'expired',
        totalAmount: 64000000,
      ),
      CampaignHistoryModel(
        id: 'ch_4',
        referenceId: 'BKG-1102-ZX',
        campaignName: 'Digital Campaign – Mall Promotion',
        location: 'Thamrin City – Fasad Utara',
        city: 'Jakarta Pusat',
        imageUrl: 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800&q=80',
        startDate: DateTime(2024, 4, 1),
        endDate: DateTime(2024, 6, 30),
        status: 'past',
        totalAmount: 84000000,
      ),
      CampaignHistoryModel(
        id: 'ch_5',
        referenceId: 'BKG-5563-GH',
        campaignName: 'Iklan Lebaran 2024',
        location: 'Kemang – Junction Board',
        city: 'Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=800&q=80',
        startDate: DateTime(2024, 3, 15),
        endDate: DateTime(2024, 4, 20),
        status: 'expired',
        totalAmount: 42000000,
      ),
    ];
  }

  // ─── FAQ ───────────────────────────────────────────────

  List<FaqModel> getFaq() {
    return [
      // ── BOOKING ──────────────────────────────────────────
      FaqModel(
        id: 'faq_1',
        category: 'Booking',
        question: 'Bagaimana cara melakukan booking billboard?',
        answer:
            'Booking billboard dilakukan melalui fitur Explore di halaman utama aplikasi. Ikuti langkah berikut:',
        infoItems: [
          'Buka tab Explore dan pilih billboard yang diinginkan',
          'Tekan tombol "Book Now" di halaman detail billboard',
          'Tentukan tanggal mulai, tanggal selesai, dan jenis durasi',
          'Tambahkan catatan jika diperlukan, lalu konfirmasi',
          'Lakukan pembayaran — booking aktif setelah pembayaran berhasil',
        ],
      ),
      FaqModel(
        id: 'faq_2',
        category: 'Booking',
        question: 'Berapa minimal periode booking billboard?',
        answer:
            'Minimal periode booking adalah 1 minggu (7 hari). Tersedia tiga pilihan durasi:',
        infoItems: [
          'Mingguan — kelipatan 7 hari (min. 1 minggu)',
          'Bulanan — kelipatan 30 hari (min. 1 bulan)',
          'Custom — tanggal bebas, minimal 7 hari',
        ],
      ),
      FaqModel(
        id: 'faq_3',
        category: 'Booking',
        question: 'Apakah booking bisa dibatalkan?',
        answer:
            'Pembatalan booking dapat dilakukan melalui menu Activity → pilih booking → tekan "Batalkan Booking". Ketentuan pembatalan:',
        infoItems: [
          'Dibatalkan > 7 hari sebelum tayang → refund penuh',
          'Dibatalkan 3–7 hari sebelum tayang → refund 50%',
          'Dibatalkan < 3 hari sebelum tayang → tidak ada refund',
          'Refund diproses dalam 3–5 hari kerja ke metode pembayaran asal',
        ],
      ),
      FaqModel(
        id: 'faq_4',
        category: 'Booking',
        question: 'Bagaimana cara memperpanjang booking?',
        answer:
            'Perpanjangan dapat dilakukan melalui menu Activity sebelum masa booking berakhir.',
        infoItems: [
          'Buka tab Activity → pilih booking yang aktif',
          'Tekan tombol "Perpanjang Booking"',
          'Pilih periode tambahan dan konfirmasi pembayaran',
          'Perpanjangan akan langsung menyambung dari tanggal akhir booking sebelumnya',
        ],
      ),
      FaqModel(
        id: 'faq_5',
        category: 'Booking',
        question: 'Bagaimana cara melihat status booking saya?',
        answer:
            'Status booking dapat dipantau secara real-time di menu Activity. Terdapat beberapa status:',
        infoItems: [
          'Pending — menunggu konfirmasi pembayaran',
          'Active — booking berjalan dan materi sedang ditayangkan',
          'Upcoming — booking terkonfirmasi, belum mulai tayang',
          'Past — booking telah selesai',
          'Cancelled — booking dibatalkan',
        ],
      ),

      // ── PEMBAYARAN ───────────────────────────────────────
      FaqModel(
        id: 'faq_6',
        category: 'Pembayaran',
        question: 'Metode pembayaran apa saja yang tersedia?',
        answer:
            'Aplikasi mendukung berbagai metode pembayaran yang dapat dikelola di menu Payment Methods:',
        infoItems: [
          'Kartu kredit/debit — Visa, Mastercard',
          'Transfer bank — BCA, Mandiri, BNI, BRI',
          'Dompet digital — GoPay, OVO, DANA',
        ],
      ),
      FaqModel(
        id: 'faq_7',
        category: 'Pembayaran',
        question: 'Kapan invoice/bukti pembayaran diterbitkan?',
        answer:
            'Invoice diterbitkan otomatis setelah pembayaran berhasil dikonfirmasi oleh sistem. Anda dapat mengaksesnya melalui:',
        infoItems: [
          'Menu Activity → pilih booking → tekan "Lihat Invoice"',
          'Invoice dapat diunduh dalam format PDF',
          'Invoice juga dikirim ke email yang terdaftar di akun Anda',
        ],
      ),
      FaqModel(
        id: 'faq_8',
        category: 'Pembayaran',
        question: 'Apakah harga yang tertera sudah termasuk pajak?',
        answer:
            'Ya, semua harga yang ditampilkan di aplikasi sudah termasuk PPN 11%. Tidak ada biaya tersembunyi. Rincian harga yang tertera:',
        infoItems: [
          'Harga sewa billboard per periode',
          'PPN 11% (sudah termasuk dalam harga)',
          'Biaya administrasi (jika ada, ditampilkan sebelum konfirmasi)',
        ],
      ),
      FaqModel(
        id: 'faq_9',
        category: 'Pembayaran',
        question: 'Bagaimana jika pembayaran gagal?',
        answer:
            'Jika pembayaran gagal, booking akan berstatus Pending selama 24 jam. Dalam periode ini Anda dapat mencoba kembali dengan:',
        infoItems: [
          'Gunakan metode pembayaran yang berbeda',
          'Pastikan saldo atau limit kartu mencukupi',
          'Coba ulangi melalui menu Activity → booking Pending → "Bayar Sekarang"',
          'Jika masih gagal setelah 24 jam, booking otomatis dibatalkan tanpa biaya',
        ],
      ),

      // ── MATERI IKLAN ─────────────────────────────────────
      FaqModel(
        id: 'faq_10',
        category: 'Materi Iklan',
        question: 'Format file materi iklan apa yang diterima?',
        answer:
            'Format yang diterima berbeda berdasarkan jenis billboard:',
        infoItems: [
          'Billboard Digital → Video: MP4 (H.264), max 30 detik',
          'Billboard Digital → Gambar: JPG/PNG, min. 1920×1080px',
          'Billboard Static → File desain: AI, PDF, CDR (resolusi 300 DPI)',
          'Ukuran file maksimum: 100MB untuk video, 50MB untuk gambar/desain',
        ],
      ),
      FaqModel(
        id: 'faq_11',
        category: 'Materi Iklan',
        question: 'Kapan harus mengunggah materi iklan?',
        answer:
            'Materi iklan harus diunggah minimal 3 hari kerja sebelum tanggal tayang dimulai agar ada waktu proses review oleh tim teknis kami.',
        infoItems: [
          'Unggah melalui: Activity → detail booking → "Upload Materi"',
          'Materi akan direview dalam 1×24 jam kerja',
          'Notifikasi persetujuan dikirim via aplikasi dan email',
          'Jika ditolak, Anda akan mendapat catatan revisi dan dapat mengupload ulang',
        ],
      ),
      FaqModel(
        id: 'faq_12',
        category: 'Materi Iklan',
        question: 'Apakah ada panduan desain materi iklan?',
        answer:
            'Ya, setiap billboard memiliki spesifikasi teknis yang dapat dilihat di halaman detail billboard. Secara umum, pastikan materi Anda:',
        infoItems: [
          'Menggunakan font minimal ukuran 36pt agar terbaca dari jarak jauh',
          'Kontras warna yang tinggi antara teks dan latar belakang',
          'Tidak memuat konten yang melanggar UU ITE dan peraturan periklanan',
          'Logo/brand terlihat jelas dalam 3 detik pertama (untuk video)',
          'Hubungi support untuk mendapatkan template desain gratis',
        ],
      ),

      // ── AKUN ─────────────────────────────────────────────
      FaqModel(
        id: 'faq_13',
        category: 'Akun',
        question: 'Bagaimana cara mengubah data profil?',
        answer:
            'Data profil dapat diubah melalui menu Profile → Personal Information.',
        infoItems: [
          'Nama lengkap, email, dan nomor HP dapat diedit langsung',
          'Foto profil dapat diperbarui dengan mengetuk ikon kamera',
          'Tekan "Save Changes" untuk menyimpan perubahan ke server',
          'Perubahan email memerlukan verifikasi ke email baru',
        ],
      ),
      FaqModel(
        id: 'faq_14',
        category: 'Akun',
        question: 'Bagaimana jika lupa password?',
        answer:
            'Ikuti langkah reset password berikut:',
        infoItems: [
          'Di halaman login, tekan "Lupa Password?"',
          'Masukkan email yang terdaftar di akun Anda',
          'Cek email masuk (termasuk folder Spam)',
          'Klik link reset password dalam email — berlaku selama 1 jam',
          'Buat password baru minimal 8 karakter dengan kombinasi huruf dan angka',
        ],
      ),
      FaqModel(
        id: 'faq_15',
        category: 'Akun',
        question: 'Bagaimana cara menghubungi admin atau support?',
        answer:
            'Ada beberapa cara untuk menghubungi tim support kami:',
        infoItems: [
          'WhatsApp: Tekan tombol "Contact Support" di menu Profile',
          'Email: support@adboardapp.id (respons 1×24 jam kerja)',
          'Jam operasional: Senin–Jumat, 09.00–17.00 WIB',
        ],
      ),
    ];
  }
}
