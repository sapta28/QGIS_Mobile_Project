import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../widgets/common_widgets.dart';
import '../controllers/profile_controller.dart';

class PaymentMethodsView extends StatefulWidget {
  const PaymentMethodsView({super.key});

  @override
  State<PaymentMethodsView> createState() => _PaymentMethodsViewState();
}

class _PaymentMethodsViewState extends State<PaymentMethodsView> {
  final _profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(40, 40),
                      ),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF059669),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Payment & Booking',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.01 * 18,
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  final displayName = _profileController.name.value;
                  final avatarUrl = _profileController.avatarUrl.value;
                  final fallbackAvatar =
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName.isNotEmpty ? displayName : "User")}&background=059669&color=fff&size=128';
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      image: DecorationImage(
                        image: getAvatarProvider(avatarUrl, fallbackAvatar),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntroCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Langkah Pemesanan & Pembayaran'),
                  const SizedBox(height: 16),
                  _buildBookingSteps(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Ketentuan Pembayaran'),
                  const SizedBox(height: 16),
                  _buildPaymentTermsCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sistem Pembayaran Terintegrasi',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Kami menggunakan sistem pembayaran otomatis melalui payment gateway TriPay untuk memudahkan Anda dalam memesan titik billboard iklan dengan aman dan terverifikasi secara instan.',
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSteps() {
    final steps = [
      _StepData(
        icon: Icons.map_outlined,
        title: 'Pilih Lokasi Billboard',
        description: 'Cari dan tentukan titik billboard strategis yang Anda inginkan melalui menu peta atau daftar billboard.',
      ),
      _StepData(
        icon: Icons.calendar_month_outlined,
        title: 'Atur Tanggal & Durasi',
        description: 'Pilih tanggal mulai pemasangan serta durasi sewa billboard (minimal sewa 1 bulan).',
      ),
      _StepData(
        icon: Icons.cloud_upload_outlined,
        title: 'Unggah Desain Kreatif',
        description: 'Unggah banner iklan Anda (.png, .jpg, .pdf) beresolusi tinggi. Anda juga dapat memilih opsi untuk mengunggah desain nanti.',
      ),
      _StepData(
        icon: Icons.payment_outlined,
        title: 'Pilih Metode Pembayaran',
        description: 'Pilih channel pembayaran yang tersedia melalui TriPay, seperti Virtual Account Bank, QRIS, atau E-Wallet.',
      ),
      _StepData(
        icon: Icons.payments_outlined,
        title: 'Bayar Down Payment (DP)',
        description: 'Lakukan pembayaran DP minimal 30% dari nilai transaksi untuk mengunci dan mengamankan pemesanan titik billboard.',
      ),
      _StepData(
        icon: Icons.assignment_turned_in_outlined,
        title: 'Verifikasi & Pelunasan',
        description: 'Admin akan memeriksa pesanan dan desain Anda. Lakukan pelunasan sebelum pemasangan banner dimulai.',
      ),
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF059669),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      step.icon,
                      size: 18,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 52,
                    color: const Color(0xFFD1FAE5),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Langkah ${index + 1}: ${step.title}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.45,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPaymentTermsCard() {
    final terms = [
      'Pembayaran Down Payment (DP) harus diselesaikan paling lambat dalam waktu 24 jam setelah proses checkout pemesanan.',
      'Jika pembayaran DP tidak diselesaikan dalam batas waktu tersebut, maka pemesanan billboard akan otomatis dibatalkan oleh sistem.',
      'Sisa pelunasan biaya sewa (70% sisanya) wajib dibayarkan sebelum banner diproduksi atau mulai dipasang di titik billboard.',
      'Desain banner yang diunggah harus memenuhi kriteria dan disetujui oleh admin. Jika ditolak, Anda dapat melakukan revisi desain di menu Activity.',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        children: terms.map((term) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4, right: 12),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFF059669),
                    size: 16,
                  ),
                ),
                Expanded(
                  child: Text(
                    term,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.45,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding > 0 ? bottomPadding + 8 : 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF059669),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'Pahami & Kembali',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.01 * 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _StepData {
  final IconData icon;
  final String title;
  final String description;

  _StepData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
