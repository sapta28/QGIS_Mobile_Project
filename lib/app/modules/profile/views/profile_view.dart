import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme.dart';
import '../controllers/profile_controller.dart';
import 'personal_information_view.dart';
import 'payment_methods_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  void _showEditProfileSheet(
    BuildContext context,
    ProfileController controller,
  ) {
    Get.bottomSheet(
      _ProfileEditSheet(
        controller: controller,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        extendBody: true,
        body: Stack(
          children: [
            const _PageBackground(),
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _UserIdentitySection(
                        controller: controller,
                        onEdit: () => _showEditProfileSheet(context, controller),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: _SectionHeader(label: 'Account'),
                    ),
                    const SizedBox(height: 12),
                    _MenuGroup(
                      items: [
                        ProfileMenuItem(
                          icon: Icons.person_outline,
                          label: 'Personal Information',
                          subtitle: 'Update your name, email, and phone',
                          onTap: () => Get.to(() => const PersonalInformationView()),
                        ),
                        ProfileMenuItem(
                          icon: Icons.credit_card_outlined,
                          label: 'Payment Methods',
                          subtitle: 'Manage cards and billing details',
                          onTap: () => Get.to(() => const PaymentMethodsView()),
                        ),
                        const ProfileMenuItem(
                          icon: Icons.notifications_outlined,
                          label: 'Notifications',
                          subtitle: 'Manage alerts for bookings and deals',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: _SectionHeader(label: 'Platform'),
                    ),
                    const SizedBox(height: 12),
                    const _MenuGroup(
                      items: [
                        ProfileMenuItem(
                          icon: Icons.favorite_outline,
                          label: 'Saved Billboards',
                          subtitle: 'View your shortlisted inventory',
                        ),
                        ProfileMenuItem(
                          icon: Icons.history,
                          label: 'Campaign History',
                          subtitle: 'Review past and active rentals',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: _SectionHeader(label: 'Support'),
                    ),
                    const SizedBox(height: 12),
                    const _MenuGroup(
                      items: [
                        ProfileMenuItem(
                          icon: Icons.help_outline,
                          label: 'Help Center',
                        ),
                        ProfileMenuItem(
                          icon: Icons.chat_bubble_outline,
                          label: 'Contact Support',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _LogoutMenuItem(controller: controller),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Text(
                        'App Version 2.4.1',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserIdentitySection extends StatelessWidget {
  const _UserIdentitySection({
    required this.controller,
    required this.onEdit,
  });

  final ProfileController controller;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final displayName =
          controller.name.value.isNotEmpty ? controller.name.value : 'Pengguna';
      final displayEmail = controller.email.value.isNotEmpty
          ? controller.email.value
          : 'email@domain.com';
      final avatarUrl = controller.avatarUrl.value;
      final fallbackAvatar =
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&background=059669&color=fff&size=256';

      return Row(
        children: [
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(
                      avatarUrl.isNotEmpty ? avatarUrl : fallbackAvatar,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF059669),
                          ),
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF059669).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayEmail,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (controller.role.value.isNotEmpty)
                      _ProfileChip(label: controller.role.value),
                    if (controller.companyId.value.isNotEmpty)
                      _ProfileChip(
                        label: 'Company ${controller.companyId.value}',
                      ),
                    if (controller.userId.value.isNotEmpty)
                      _ProfileChip(label: 'ID ${controller.userId.value}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: const Color(0xFF0F172A),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<ProfileMenuItem> items;

  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isLast = index == items.length - 1;
            return _MenuTile(
              item: item,
              showDivider: !isLast,
            );
          }),
        ),
      ),
    );
  }
}

class ProfileMenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.iconColor,
    this.onTap,
  });
}

class _MenuTile extends StatelessWidget {
  final ProfileMenuItem item;
  final bool showDivider;

  const _MenuTile({required this.item, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: showDivider
            ? BorderRadius.zero
            : const BorderRadius.vertical(bottom: Radius.circular(24)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  _IconContainer(icon: item.icon, color: item.iconColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFCBD5E1),
                    size: 24,
                  ),
                ],
              ),
            ),
            if (showDivider)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 76,
                endIndent: 20,
                color: Color(0xFFF1F5F9),
              ),
          ],
        ),
      ),
    );
  }
}

class _IconContainer extends StatelessWidget {
  final IconData icon;
  final Color? color;

  const _IconContainer({required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFF0FDF4),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color ?? const Color(0xFF059669), size: 22),
    );
  }
}

class _LogoutMenuItem extends StatelessWidget {
  const _LogoutMenuItem({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () async {
          final confirmed = await Get.dialog<bool>(
            AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Keluar akun?',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              content: Text(
                'Sesi kamu akan dihapus dari perangkat ini.',
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Get.back(result: true),
                  child: Text(
                    'Logout',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await controller.logout();
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Log Out',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileEditSheet extends StatefulWidget {
  const _ProfileEditSheet({
    required this.controller,
  });

  final ProfileController controller;

  @override
  State<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<_ProfileEditSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.controller.name.value);
    _emailController =
        TextEditingController(text: widget.controller.email.value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Edit Profil',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Nama',
                labelStyle: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5),
                ),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),
            Obx(() {
              final isSaving = widget.controller.isSaving.value;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final success = await widget.controller.updateProfile(
                            name: _nameController.text,
                            email: _emailController.text,
                          );
                          if (success) {
                            Get.back();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    disabledBackgroundColor: const Color(0xFF059669).withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          'Simpan',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
}

class _PageBackground extends StatelessWidget {
  const _PageBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF8FAFC),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.5,
            child: Image.network(
              'https://images.unsplash.com/photo-1514565131-fce0801e5785?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Container(
            color: const Color(0xFF059669).withOpacity(0.12),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFD1FAE5).withOpacity(0.95),
                    const Color(0xFFD1FAE5).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: Icon(Icons.cloud_rounded, color: Colors.white.withOpacity(0.9), size: 48),
          ),
          Positioned(
            top: 100,
            left: -15,
            child: Icon(Icons.cloud_rounded, color: Colors.white.withOpacity(0.7), size: 72),
          ),
          Positioned(
            top: 35,
            right: 40,
            child: Icon(Icons.cloud_rounded, color: Colors.white.withOpacity(0.9), size: 36),
          ),
          Positioned(
            top: 85,
            right: -25,
            child: Icon(Icons.cloud_rounded, color: Colors.white.withOpacity(0.8), size: 85),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF8FAFC).withOpacity(0.1),
                  const Color(0xFFF8FAFC).withOpacity(0.85),
                  const Color(0xFFF8FAFC),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}