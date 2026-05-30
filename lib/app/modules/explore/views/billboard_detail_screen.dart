import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/theme.dart';
import '../../../../models/models.dart';
import '../../../../widgets/common_widgets.dart';
import '../../../data/services/api/user_api_service.dart';
import '../../home/controllers/home_controller.dart';
import '../../activity/controllers/activity_controller.dart';
import 'booking_confirmation_screen.dart';
import 'tripay_checkout_webview.dart';

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
              SliverToBoxAdapter(
                child: _HeroImageSection(billboard: billboard),
              ),
              SliverToBoxAdapter(
                child: _DetailSheet(billboard: billboard),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
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
          CachedNetworkImage(
            imageUrl: billboard.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.surfaceContainerHigh,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.surfaceContainerHigh,
              child: const Icon(Icons.image, color: AppColors.outline, size: 64),
            ),
          ),
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

  String _formatRupiah(double amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final bool actuallyAvailable = billboard.isAvailable && !billboard.isHeldByOthers;
    final bool isHeldByOthers = billboard.isHeldByOthers;
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
            Row(
              // ...
              children: [
                // UPDATE BADGE STATUS
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isHeldByOthers 
                        ? const Color(0xFFFEF3C7) // Kuning lembut
                        : actuallyAvailable
                            ? AppColors.surfaceContainerHigh
                            : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isHeldByOthers
                        ? 'Dipesan (Menunggu DP)'
                        : actuallyAvailable
                            ? 'Available Now'
                            : 'Not Available',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.05 * 12,
                      color: isHeldByOthers
                          ? const Color(0xFFB45309) // Coklat tua
                          : actuallyAvailable
                              ? AppColors.primary
                              : AppColors.outline,
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: _formatRupiah(billboard.pricePerWeek),
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.01 * 18,
                        ),
                      ),
                      TextSpan(
                        text: ' / month',
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
                    subtitle: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StickyBookButton extends StatefulWidget {
  final BillboardModel billboard;
  // Tangkap tanggal yang dipilih dari Peta/Controller
  final DateTime? startDate;
  final DateTime? endDate;

  const _StickyBookButton({
    super.key, 
    required this.billboard,
    this.startDate,
    this.endDate,
  });

  @override
  State<_StickyBookButton> createState() => _StickyBookButtonState();
}

class _StickyBookButtonState extends State<_StickyBookButton> {
  bool _isRequestingReminder = false;
  bool _reminderSet = false;

  UserApiService get _userApiService => Get.find<UserApiService>();

  // Fungsi untuk memanggil API Reminder
  Future<void> _handleRemindMe() async {
    if (_reminderSet || _isRequestingReminder) return;
    
    // Validasi tanggal wajib ada
    if (widget.startDate == null || widget.endDate == null) {
      Get.snackbar('Ketersediaan', 'Pilih tanggal sewa di peta terlebih dahulu untuk menyetel pengingat.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFBBF24),
          colorText: const Color(0xFF78350F));
      return;
    }

    setState(() => _isRequestingReminder = true);
    
    try {
      final response = await _userApiService.setBillboardReminder(
        billboardId: widget.billboard.id,
        startDate: widget.startDate!.toIso8601String().split('T').first,
        endDate: widget.endDate!.toIso8601String().split('T').first,
      );

      if (mounted) {
        setState(() => _reminderSet = true);
        Get.snackbar('Pengingat Disetel', response['message'] ?? 'Kami akan mengabari Anda jika titik ini tersedia.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF059669),
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white));
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan saat menyetel pengingat.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isRequestingReminder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.billboard;
    // Status logika tombol:
    // 1. Fully Available -> Book Now
    // 2. Held by Others (DP Pending/Waiting Admin) -> Remind Me
    // 3. Not Available (Active/Lunas) -> Not Available (Disabled)
    final bool isHeldByOthers = b.isHeldByOthers;
    final bool actuallyAvailable = b.isAvailable && !isHeldByOthers;

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
      child: isHeldByOthers
          ? // SKU 2: Tombol Ingatkan Saya (Kuning)
          ElevatedButton.icon(
              onPressed: (_isRequestingReminder || _reminderSet) ? null : _handleRemindMe,
              icon: _isRequestingReminder
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB45309)))
                  : Icon(_reminderSet ? Icons.notifications_active : Icons.notifications_none_rounded, size: 20),
              label: Text(
                _isRequestingReminder
                    ? 'Processing...'
                    : _reminderSet
                        ? 'Pengingat Disetel'
                        : 'Ingatkan jika Tersedia',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.01 * 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBBF24), // Kuning Amber
                foregroundColor: const Color(0xFF78350F), // Coklat tua
                disabledBackgroundColor: const Color(0xFFFBBF24).withOpacity(0.5),
                disabledForegroundColor: const Color(0xFF78350F).withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            )
          : actuallyAvailable
              ? // SKU 1: Tombol Book Now (Biru/Primary)
              PrimaryButton(
                  label: 'Book Now',
                  trailingIcon: Icons.arrow_forward,
                  onPressed: () {
                    Get.to(() => BookingScreen(billboard: b), transition: Transition.rightToLeft);
                  },
                )
              : // SKU 3: Tombol Not Available (Abu-abu/Disabled)
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      disabledBackgroundColor: AppColors.surfaceContainerHigh,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Tidak Tersedia',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.outline),
                    ),
                  ),
                ),
    );
  }
}

class BookingScreen extends StatefulWidget {
  final BillboardModel billboard;
  const BookingScreen({super.key, required this.billboard});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _notesController = TextEditingController();

  DateTime? _startDate;
  int _months = 1;
  bool _isSubmitting = false;
  String? _uploadedFileName;
  String? _uploadedFilePath;
  bool _uploadDesignLater = false;

  UserApiService get _userApiService => Get.find<UserApiService>();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  DateTime? get _endDate {
    if (_startDate == null) return null;
    final start = _startDate!;
    int newMonth = start.month + _months;
    int newYear = start.year + (newMonth - 1) ~/ 12;
    newMonth = ((newMonth - 1) % 12) + 1;
    final rawEnd = DateTime(newYear, newMonth, start.day);
    return rawEnd.subtract(const Duration(days: 1));
  }

  String _displayDate(DateTime? value) {
    if (value == null) return 'dd/mm/yyyy';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dd = value.day.toString().padLeft(2, '0');
    return '$dd ${months[value.month - 1]} ${value.year}';
  }

  String _apiDate(DateTime? value) {
    if (value == null) return '';
    final mm = value.month.toString().padLeft(2, '0');
    final dd = value.day.toString().padLeft(2, '0');
    return '${value.year}-$mm-$dd';
  }

  double get _monthlyRate => widget.billboard.pricePerWeek;
  double get _totalPrice => _monthlyRate * _months;
  double get _printFee => widget.billboard.printFee ?? 15;
  double get _installFee => widget.billboard.installFee ?? 50;
  double get _subtotal => _totalPrice + _printFee + _installFee;
  double get _taxRate => widget.billboard.taxRate ?? 0.1;
  double get _tax => _subtotal * _taxRate;
  double get _grandTotal => _subtotal + _tax;
  double get _downPaymentRate => widget.billboard.downPaymentRate ?? 0.3;
  double get _downPayment => _grandTotal * _downPaymentRate;
  double get _remainingBalance => _grandTotal - _downPayment;

  String _formatMoney(double amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _startDate = picked);
  }

  Future<void> _submitBooking() async {
    if (_isSubmitting) return;
    if (_startDate == null) {
      Get.snackbar('Booking', 'Pilih tanggal mulai terlebih dahulu.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (! _uploadDesignLater && (_uploadedFilePath == null || _uploadedFilePath!.isEmpty)) {
      Get.snackbar(
        'Booking',
        'Silakan unggah file desain atau aktifkan opsi unggah nanti.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await _userApiService.bookSpot(
        spotId: widget.billboard.id,
        startDate: _apiDate(_startDate),
        endDate: _apiDate(_endDate),
        durationType: 'monthly',
        durationValue: _months,
        paymentMethod: 'tripay',
        uploadDesignLater: _uploadDesignLater,
        notes: _notesController.text.trim(),
      );

      String refId = 'BKG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      String? checkoutUrl = response['checkout_url'] as String?;
      final data = response['data'];
      
      if (data is Map<String, dynamic>) {
        refId = (data['reference_id'] ?? data['invoice_no'] ?? data['id']?.toString() ?? refId).toString();
        checkoutUrl ??= data['checkout_url'] as String?;
      }

      if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
        final paid = await Get.to<bool>(
          () => TriPayCheckoutWebView(
            checkoutUrl: checkoutUrl!,
            title: 'TriPay Payment',
          ),
          fullscreenDialog: true,
        );

        if (paid == true && mounted) {
          Get.until((route) => route.isFirst);
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().changeNav(1);
          }
          if (Get.isRegistered<ActivityController>()) {
            Get.find<ActivityController>().fetchActivities(status: null);
          }
        }
      } else {
        Get.off(
          () => BookingConfirmationScreen(
            billboardName: widget.billboard.name,
            startDate: _displayDate(_startDate),
            endDate: _displayDate(_endDate),
            referenceId: refId,
            checkoutUrl: checkoutUrl,
          ),
          transition: Transition.fade,
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Gagal membuat booking.';
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        if (responseData['message'] != null) {
          errorMessage = responseData['message'].toString();
        }
      }
      Get.snackbar(
        'Pemesanan Gagal',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan tidak terduga.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickDesignFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final selected = result.files.first;
    setState(() {
      _uploadedFileName = selected.name;
      _uploadedFilePath = selected.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBillboardSummary(),
                  const SizedBox(height: 24),
                  _buildCampaignDates(),
                  const SizedBox(height: 24),
                  _buildCreativeUpload(),
                  const SizedBox(height: 24),
                  _buildAdditionalNotes(),
                  const SizedBox(height: 24),
                  _buildPriceSummary(),
                  const SizedBox(height: 24),
                  _buildCheckoutSummary(),
                  const SizedBox(height: 24),
                  _buildConfirmButton(),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.surface.withOpacity(0.9),
      padding: EdgeInsets.fromLTRB(4, MediaQuery.of(context).padding.top + 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 24),
            color: AppColors.onSurface,
            splashRadius: 22,
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Text(
              'Book Billboard',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.01 * 20,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillboardSummary() {
    final b = widget.billboard;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 30,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: CachedNetworkImage(
                imageUrl: b.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.surfaceContainerHigh,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceContainerHigh,
                  child: const Icon(Icons.image, color: AppColors.outline, size: 32),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    b.type,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.05 * 12,
                      color: AppColors.onPrimaryFixed,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  b.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.01 * 16,
                    color: AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${b.location}, ${b.city}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignDates() {
    final end = _endDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durasi Sewa',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01 * 20,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tanggal Mulai',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickStartDate,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _startDate != null ? AppColors.primary : AppColors.outlineVariant,
                width: _startDate != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: _startDate != null ? AppColors.primary : AppColors.outline,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _displayDate(_startDate),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: _startDate != null ? FontWeight.w600 : FontWeight.w400,
                      color: _startDate != null ? AppColors.onSurface : AppColors.outline,
                    ),
                  ),
                ),
                Icon(
                  Icons.edit_calendar_outlined,
                  size: 18,
                  color: _startDate != null ? AppColors.primary : AppColors.outline,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Lama Sewa',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              _monthButton(
                icon: Icons.remove,
                onTap: _months > 1 ? () => setState(() => _months--) : null,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$_months',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      _months == 1 ? 'bulan' : 'bulan',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _monthButton(
                icon: Icons.add,
                onTap: _months < 24 ? () => setState(() => _months++) : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_startDate != null && end != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.date_range, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_displayDate(_startDate)}  →  ${_displayDate(end)}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _monthButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.onPrimary : AppColors.outline,
        ),
      ),
    );
  }

  Widget _buildCreativeUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Creative Upload',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01 * 20,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload your ad creative. High-res PNG or JPG (Max 50MB).',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: _uploadDesignLater,
          onChanged: (value) {
            setState(() {
              _uploadDesignLater = value ?? false;
              if (_uploadDesignLater) {
                _uploadedFileName = null;
                _uploadedFilePath = null;
              }
            });
          },
          contentPadding: EdgeInsets.zero,
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            'Unggah desain nanti',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          subtitle: Text(
            'Booking titik dulu, desain bisa menyusul setelah DP dibayar.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          activeColor: AppColors.primary,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _uploadDesignLater
              ? null
              : _pickDesignFile,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: _uploadDesignLater
                  ? AppColors.surfaceContainerHigh.withOpacity(0.55)
                  : _uploadedFileName != null
                  ? AppColors.primaryFixed.withOpacity(0.15)
                  : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _uploadDesignLater
                    ? AppColors.outlineVariant
                    : _uploadedFileName != null
                    ? AppColors.primary
                    : AppColors.outlineVariant,
                style: BorderStyle.solid,
                width: _uploadDesignLater || _uploadedFileName != null ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _uploadDesignLater
                      ? Icons.schedule_send
                      : _uploadedFileName != null
                      ? Icons.check_circle_outline
                      : Icons.cloud_upload_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                if (_uploadDesignLater) ...[
                  Text(
                    'Desain akan diunggah nanti',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Form ini tetap bisa diproses untuk booking dan DP.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ] else if (_uploadedFileName != null) ...[
                  Text(
                    _uploadedFileName!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to change file',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Upload a file',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(
                          text: ' or drag and drop',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1080×1920px recommended',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01 * 20,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 4,
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: 'Any specific instructions for the display?',
            hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.outline),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _priceRow(
            label: 'Harga / Bulan',
            value: _formatMoney(_monthlyRate),
            isTotal: false,
          ),
          const SizedBox(height: 8),
          _priceRow(
            label: 'Durasi',
            value: '$_months Bulan',
            isTotal: false,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              color: AppColors.outlineVariant,
              height: 1,
              thickness: 0.4,
            ),
          ),
          _priceRow(
            label: 'Total',
            value: _startDate != null ? _formatMoney(_totalPrice) : '—',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Checkout',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _priceRow(label: 'Biaya Sewa (${_months} Bulan)', value: _formatMoney(_totalPrice), isTotal: false),
          const SizedBox(height: 8),
          _priceRow(label: 'Biaya Cetak MMT', value: _formatMoney(_printFee), isTotal: false),
          const SizedBox(height: 8),
          _priceRow(label: 'Biaya Pasang', value: _formatMoney(_installFee), isTotal: false),
          const SizedBox(height: 8),
          _priceRow(label: 'PPN (11%)', value: _formatMoney(_tax), isTotal: false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              color: AppColors.outlineVariant,
              height: 1,
              thickness: 0.4,
            ),
          ),
          _priceRow(label: 'Total Harga', value: _formatMoney(_grandTotal), isTotal: true),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tagihan Saat Ini (DP 30%)',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatMoney(_downPayment),
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sisa pelunasan: ${_formatMoney(_remainingBalance)}',
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
    );
  }

  Widget _priceRow({
    required String label,
    required String value,
    required bool isTotal,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16 : 15,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal ? AppColors.onSurface : AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w700,
            letterSpacing: isTotal ? -0.02 * 20 : 0.01 * 16,
            color: isTotal ? AppColors.primary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitBooking,
        icon: _isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: AppColors.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.arrow_forward, size: 20),
        label: Text(
          _isSubmitting ? 'Processing...' : 'Lanjutkan Pembayaran DP',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01 * 16,
          ),
        ),
        iconAlignment: IconAlignment.end,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          disabledForegroundColor: AppColors.onPrimary.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          shadowColor: AppColors.primary.withOpacity(0.2),
        ),
      ),
    );
  }
}

class BookingConfirmationScreen extends StatefulWidget {
  final String billboardName;
  final String startDate;
  final String endDate;
  final String referenceId;
  final String? checkoutUrl;

  const BookingConfirmationScreen({
    super.key,
    required this.billboardName,
    required this.startDate,
    required this.endDate,
    required this.referenceId,
    this.checkoutUrl,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _checkoutOpened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openCheckoutIfAvailable();
    });
  }

  String get _campaignDates => '${widget.startDate} – ${widget.endDate}';

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
                  _buildCheckIcon(),
                  const SizedBox(height: 28),
                  Text(
                    widget.checkoutUrl != null && widget.checkoutUrl!.isNotEmpty
                        ? 'Pembayaran DP Siap'
                        : 'Booking Submitted!',
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
                    widget.checkoutUrl != null && widget.checkoutUrl!.isNotEmpty
                        ? 'Booking berhasil dibuat. Lanjut bayar DP lewat Tripay, lalu kamu akan masuk ke status tracker.'
                        : 'Booking berhasil dibuat. Tim kami akan meninjau pesananmu.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSummaryCard(),
                  const SizedBox(height: 32),
                  _buildWorkflowCard(),
                  const SizedBox(height: 32),
                  _buildButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckIcon() {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryFixed.withOpacity(0.5),
            ),
            width: 80,
            height: 80,
          ),
          const Icon(
            Icons.check_circle,
            size: 52,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

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
          _summaryRow(
            label: 'Billboard',
            value: widget.billboardName,
            valueColor: AppColors.onSurface,
          ),
          _divider(),
          _summaryRow(
            label: 'Campaign Dates',
            value: _campaignDates,
            valueColor: AppColors.onSurface,
          ),
          _divider(),
          _summaryRow(
            label: 'Reference ID',
            value: widget.referenceId,
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

  Widget _buildWorkflowCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Tracker',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pembayaran DP dilakukan lewat Tripay agar slot langsung terkunci setelah pembayaran berhasil.',
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.4,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _workflowRow(
            index: 1,
            title: 'Bayar DP',
            subtitle: 'Checkout Tripay dibuka untuk menyelesaikan pembayaran termin 1.',
            active: true,
          ),
          _workflowConnector(active: true),
          _workflowRow(
            index: 2,
            title: 'DP Lunas',
            subtitle: 'Slot reklame terkunci setelah pembayaran DP berhasil.',
            active: false,
          ),
          _workflowConnector(active: false),
          _workflowRow(
            index: 3,
            title: 'Menunggu Approval',
            subtitle: 'Admin meninjau desain dan memberi status approve / reject.',
            active: false,
          ),
          _workflowConnector(active: false),
          _workflowRow(
            index: 4,
            title: 'Menunggu Pelunasan',
            subtitle: 'Termin 2 terbit setelah desain disetujui.',
            active: false,
          ),
          _workflowConnector(active: false),
          _workflowRow(
            index: 5,
            title: 'Ready to Install',
            subtitle: 'Pekerjaan lapangan bisa dimulai setelah pelunasan.',
            active: false,
          ),
        ],
      ),
    );
  }

  Widget _workflowRow({
    required int index,
    required String title,
    required String subtitle,
    required bool active,
  }) {
    final color = active ? const Color(0xFF059669) : AppColors.outline;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE7F8EF) : AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Center(
            child: Text(
              '$index',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _workflowConnector({required bool active}) {
    return Padding(
      padding: const EdgeInsets.only(left: 13, top: 4, bottom: 4),
      child: Container(
        width: 2,
        height: 14,
        color: active ? const Color(0xFFB7E4C7) : AppColors.outlineVariant,
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        if (widget.checkoutUrl != null && widget.checkoutUrl!.isNotEmpty) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                shadowColor: const Color(0xFF059669).withOpacity(0.25),
              ),
              child: Text(
                'Bayar Sekarang',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.01 * 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _goToBookingsTab();
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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
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

  Future<void> _openCheckout() async {
    final url = widget.checkoutUrl;
    if (url == null || url.isEmpty) {
      Get.snackbar('Payment', 'Link pembayaran belum tersedia.');
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      Get.snackbar('Payment', 'Link pembayaran tidak valid.');
      return;
    }

    final paid = await Get.to<bool>(
      () => TriPayCheckoutWebView(
        checkoutUrl: uri.toString(),
        title: 'TriPay Payment',
      ),
      fullscreenDialog: true,
    );

    if (paid == true && mounted) {
      _goToBookingsTab();
    }
  }

  Future<void> _openCheckoutIfAvailable() async {
    if (_checkoutOpened) return;
    final url = widget.checkoutUrl;
    if (url == null || url.isEmpty) return;

    _checkoutOpened = true;
    await _openCheckout();
  }

  void _goToBookingsTab() {
    Get.until((route) => route.isFirst);
    Get.find<HomeController>().changeNav(1);
    if (Get.isRegistered<ActivityController>()) {
      Get.find<ActivityController>().fetchActivities(status: null);
    }
  }
}