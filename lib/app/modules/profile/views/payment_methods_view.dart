import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme.dart';
import '../controllers/payment_methods_controller.dart';
import '../../../data/services/profile_mock_service.dart';

class PaymentMethodsView extends GetView<PaymentMethodsController> {
  const PaymentMethodsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return _buildErrorState();
              }
              return RefreshIndicator(
                onRefresh: controller.fetchMethods,
                color: AppColors.primary,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    _buildSectionLabel('KARTU & METODE TERSIMPAN'),
                    const SizedBox(height: 12),
                    Obx(() => Column(
                          children: controller.methods.map((method) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _PaymentCard(
                                method: method,
                                onSetDefault: () =>
                                    controller.setDefault(method.id),
                                onDelete: () =>
                                    _confirmDelete(context, method),
                              ),
                            );
                          }).toList(),
                        )),
                    const SizedBox(height: 4),
                    _buildAddNewButton(context),
                    const SizedBox(height: 28),
                    _buildSectionLabel('OPSI LAINNYA'),
                    const SizedBox(height: 12),
                    _buildOptionRow(
                      icon: Icons.account_balance_outlined,
                      title: 'Transfer Bank',
                      subtitle: 'BCA, Mandiri, BNI, BRI',
                      onTap: () => _showComingSoon('Transfer Bank'),
                    ),
                    const SizedBox(height: 10),
                    _buildOptionRow(
                      icon: Icons.wallet_outlined,
                      title: 'Dompet Digital',
                      subtitle: 'GoPay, OVO, DANA',
                      onTap: () => _showComingSoon('Dompet Digital'),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            bottom: BorderSide(
              color: AppColors.outlineVariant.withOpacity(0.3),
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
            ),
            Expanded(
              child: Text(
                'Payment Methods',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.onSurfaceVariant.withOpacity(0.7),
      ),
    );
  }

  Widget _buildAddNewButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showAddMethodSheet(context),
      icon: const Icon(Icons.add_rounded, size: 20, color: AppColors.primary),
      label: Text(
        'Tambah Metode Baru',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(
          color: AppColors.primary.withOpacity(0.4),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.outline, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(controller.errorMessage.value,
              style: GoogleFonts.inter(color: AppColors.onSurface)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.fetchMethods,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, PaymentMethodModel method) async {
    if (method.isDefault) {
      Get.snackbar(
        'Tidak dapat dihapus',
        'Metode pembayaran utama tidak dapat dihapus.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Hapus Metode?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
          'Metode pembayaran "${method.brand} ****${method.lastFour}" akan dihapus.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteMethod(method.id);
    }
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Segera Hadir',
      'Metode $feature akan segera tersedia.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showAddMethodSheet(BuildContext context) {
    Get.bottomSheet(
      _AddPaymentMethodSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }
}

// ─── Payment Card Widget ──────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final PaymentMethodModel method;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _PaymentCard({
    required this.method,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isWallet = method.type == 'wallet';
    final brandColor = _brandColor(method.brand);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: method.isDefault
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.outlineVariant.withOpacity(0.2),
          width: method.isDefault ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MethodIcon(brand: method.brand, color: brandColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.brand,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (!isWallet)
                      Text(
                        '•••• •••• •••• ${method.lastFour}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 1,
                        ),
                      )
                    else
                      Text(
                        'E-Wallet',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'default') onSetDefault();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  if (!method.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded,
                              color: AppColors.primary, size: 18),
                          SizedBox(width: 8),
                          Text('Jadikan Utama'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            color: AppColors.error, size: 18),
                        SizedBox(width: 8),
                        Text('Hapus',
                            style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert_rounded,
                    color: AppColors.outline, size: 20),
              ),
            ],
          ),
          if (!isWallet && method.expiry.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'EXPIRED',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  method.expiry,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ],
          if (method.isDefault) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'METODE UTAMA',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onSetDefault,
              child: Text(
                'Jadikan metode utama',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withOpacity(0.7),
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _brandColor(String brand) {
    return switch (brand.toLowerCase()) {
      'visa' => const Color(0xFF1A1F71),
      'mastercard' => const Color(0xFFEB001B),
      'gopay' => const Color(0xFF00AED6),
      'ovo' => const Color(0xFF4C3494),
      'dana' => const Color(0xFF118EEA),
      _ => AppColors.primary,
    };
  }
}

class _MethodIcon extends StatelessWidget {
  final String brand;
  final Color color;
  const _MethodIcon({required this.brand, required this.color});

  @override
  Widget build(BuildContext context) {
    final icon = switch (brand.toLowerCase()) {
      'visa' || 'mastercard' => Icons.credit_card_rounded,
      'gopay' || 'ovo' || 'dana' => Icons.account_balance_wallet_rounded,
      _ => Icons.payments_rounded,
    };
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

// ─── Add Payment Method Sheet ─────────────────────────────

class _AddPaymentMethodSheet extends StatefulWidget {
  final PaymentMethodsController controller;
  const _AddPaymentMethodSheet({required this.controller});

  @override
  State<_AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends State<_AddPaymentMethodSheet> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'credit_card';
  String _selectedBrand = 'Visa';
  final _lastFourCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();

  final _cardBrands = ['Visa', 'Mastercard'];
  final _walletBrands = ['GoPay', 'OVO', 'DANA'];

  @override
  void dispose() {
    _lastFourCtrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isCard = _selectedType == 'credit_card';
    final brands = isCard ? _cardBrands : _walletBrands;
    if (!brands.contains(_selectedBrand)) {
      _selectedBrand = brands.first;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tambah Metode Pembayaran',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            // Type selector
            Row(
              children: [
                _TypeChip(
                  label: 'Kartu Kredit/Debit',
                  selected: _selectedType == 'credit_card',
                  onTap: () => setState(() {
                    _selectedType = 'credit_card';
                    _selectedBrand = 'Visa';
                  }),
                ),
                const SizedBox(width: 10),
                _TypeChip(
                  label: 'E-Wallet',
                  selected: _selectedType == 'wallet',
                  onTap: () => setState(() {
                    _selectedType = 'wallet';
                    _selectedBrand = 'GoPay';
                  }),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Brand',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedBrand,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: brands
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedBrand = v!),
            ),
            if (isCard) ...[
              const SizedBox(height: 14),
              Text('4 Digit Terakhir',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastFourCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  hintText: '1234',
                  counterText: '',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                validator: (v) => (v == null || v.length < 4)
                    ? 'Masukkan 4 digit terakhir'
                    : null,
              ),
              const SizedBox(height: 14),
              Text('Tanggal Kedaluwarsa',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _expiryCtrl,
                keyboardType: TextInputType.datetime,
                maxLength: 5,
                decoration: InputDecoration(
                  hintText: 'MM/YY',
                  counterText: '',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                onChanged: (v) {
                  if (v.length == 2 && !v.contains('/')) {
                    _expiryCtrl.text = '$v/';
                    _expiryCtrl.selection = TextSelection.fromPosition(
                      TextPosition(offset: _expiryCtrl.text.length),
                    );
                  }
                },
                validator: (v) {
                  if (v == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) {
                    return 'Format MM/YY';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 20),
            Obx(() {
              final saving = widget.controller.isSaving.value;
              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Tambahkan',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final method = PaymentMethodModel(
      id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
      type: _selectedType,
      brand: _selectedBrand,
      lastFour: _selectedType == 'credit_card' ? _lastFourCtrl.text : '',
      expiry: _selectedType == 'credit_card' ? _expiryCtrl.text : '',
      isDefault: false,
    );
    await widget.controller.addMethod(method);
    if (mounted) Get.back();
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
