import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme.dart';
import '../controllers/profile_controller.dart';

class PaymentMethodsView extends StatefulWidget {
  const PaymentMethodsView({super.key});

  @override
  State<PaymentMethodsView> createState() => _PaymentMethodsViewState();
}

class _PaymentMethodsViewState extends State<PaymentMethodsView> {
  final _profileController = Get.find<ProfileController>();

  void _handleConfirm() {
    Get.snackbar(
      'Payment Methods',
      'Payment preferences confirmed successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.9),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.outlineVariant.withOpacity(0.3),
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
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Payment Methods',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -0.01 * 18,
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  final displayName = _profileController.name.value;
                  final avatarUrl = _profileController.avatarUrl.value;
                  final fallbackAvatar =
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName.isNotEmpty ? displayName : "User")}&background=003ec7&color=fff&size=128';
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.outlineVariant.withOpacity(0.2),
                        width: 1,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(avatarUrl.isNotEmpty ? avatarUrl : fallbackAvatar),
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
                  // Saved cards section header
                  _buildSectionHeader('Saved Cards', '2 TOTAL'),
                  const SizedBox(height: 12),

                  // Card 1: Default Visa
                  _buildPaymentCard(
                    isDefault: true,
                    icon: Icons.credit_card_rounded,
                    brandName: 'Visa',
                    cardNumber: '••••  ••••  ••••  4242',
                    expiry: '12/25',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 14),

                  // Card 2: Mastercard
                  _buildPaymentCard(
                    isDefault: false,
                    icon: Icons.payments_outlined,
                    brandName: 'Mastercard',
                    cardNumber: '••••  ••••  ••••  8812',
                    expiry: '09/24',
                    color: const Color(0xFF7C5800), // secondary/gold tint
                    opacity: 0.8,
                  ),
                  const SizedBox(height: 16),

                  // Add New Method Button (dashed-style container)
                  _buildAddNewMethodButton(),
                  const SizedBox(height: 32),

                  // Billing Address Section
                  _buildSectionHeader('Billing Address', null),
                  const SizedBox(height: 12),
                  _buildBillingAddressCard(),
                  const SizedBox(height: 28),

                  // Other Options
                  _buildOptionRow(
                    icon: Icons.account_balance_outlined,
                    title: 'Bank Account (ACH)',
                  ),
                  const SizedBox(height: 10),
                  _buildOptionRow(
                    icon: Icons.wallet_outlined,
                    title: 'Digital Wallets',
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
          // Confirm changes bottom button
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? trailingText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.05 * 12,
            color: AppColors.onSurfaceVariant.withOpacity(0.8),
          ),
        ),
        if (trailingText != null)
          Text(
            trailingText,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.05 * 12,
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentCard({
    required bool isDefault,
    required IconData icon,
    required String brandName,
    required String cardNumber,
    required String expiry,
    required Color color,
    double opacity = 1.0,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDefault) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'DEFAULT',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.05 * 10,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Icon(
                      icon,
                      color: color,
                      size: 32,
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              cardNumber,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1 * 18,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPIRY',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.05 * 10,
                        color: AppColors.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      expiry,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                Text(
                  brandName,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: color.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewMethodButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(
            color: AppColors.outlineVariant.withOpacity(0.5),
            width: 1.5,
            style: BorderStyle.solid, // Note: standard flutter doesn't do dashed out of box, so we use solid with opacity.
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Add New Method',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingAddressCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.outlineVariant.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Primary Residence',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '725 Highview Towers, Suite 402\nFinancial District, Metropolis 10122\nUnited States',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.45,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.edit_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String title,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.onSurfaceVariant,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.outline,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding > 0 ? bottomPadding + 8 : 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withOpacity(0.25),
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 2,
            shadowColor: AppColors.primary.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'Confirm Changes',
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
