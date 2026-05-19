import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // User Identity Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _UserIdentitySection(),
              ),
              const SizedBox(height: 24),
              // Account Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SectionHeader(label: 'Account'),
              ),
              const SizedBox(height: 8),
              _MenuGroup(
                items: const [
                  ProfileMenuItem(
                    icon: Icons.person_outline,
                    label: 'Personal Information',
                    subtitle: 'Update your name, email, and phone',
                  ),
                  ProfileMenuItem(
                    icon: Icons.credit_card_outlined,
                    label: 'Payment Methods',
                    subtitle: 'Manage cards and billing details',
                  ),
                  ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    subtitle: 'Manage alerts for bookings and deals',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Platform Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SectionHeader(label: 'Platform'),
              ),
              const SizedBox(height: 8),
              _MenuGroup(
                items: const [
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
              const SizedBox(height: 20),
              // Support Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SectionHeader(label: 'Support'),
              ),
              const SizedBox(height: 8),
              _MenuGroup(
                items: const [
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
              const SizedBox(height: 12),
              // Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _LogoutMenuItem(),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'App Version 2.4.1',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.outlineVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserIdentitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surfaceContainerLowest,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://ui-avatars.com/api/?name=Alex+Mercer&background=003ec7&color=fff&size=256',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sapta Adzani',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.02 * 24,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'sapta.adzani@gmail.com',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Verified Buyer',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.05 * 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05 * 12,
          color: AppColors.onSurfaceVariant,
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 16,
              offset: const Offset(0, 4),
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

  const ProfileMenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.iconColor,
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
        onTap: () {},
        borderRadius: showDivider
            ? BorderRadius.zero
            : const BorderRadius.vertical(bottom: Radius.circular(16)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
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
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurface,
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.outlineVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
            if (showDivider)
              const Divider(
                height: 1,
                thickness: 0.5,
                indent: 72,
                color: AppColors.outlineVariant,
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color ?? AppColors.primary, size: 20),
    );
  }
}

class _LogoutMenuItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () async {
          final confirmed = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Keluar akun?'),
              content: const Text('Sesi kamu akan dihapus dari perangkat ini.'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await Get.find<ProfileController>().logout();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.errorContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Log Out',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}