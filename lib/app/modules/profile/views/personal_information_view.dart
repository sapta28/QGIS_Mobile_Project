import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme.dart';
import '../controllers/profile_controller.dart';

class PersonalInformationView extends StatefulWidget {
  const PersonalInformationView({super.key});

  @override
  State<PersonalInformationView> createState() => _PersonalInformationViewState();
}

class _PersonalInformationViewState extends State<PersonalInformationView> {
  final _profileController = Get.find<ProfileController>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _profileController.name.value);
    _emailController = TextEditingController(text: _profileController.email.value);
    _phoneController = TextEditingController(text: '+1 234 567 890');
    _locationController = TextEditingController(text: 'New York, USA');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Call controller to update name & email on backend
    final success = await _profileController.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );

    if (success && mounted) {
      Get.snackbar(
        'Success',
        'Profile information saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );
    }
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
                      'Personal Information',
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar profile picture section
                    _buildAvatarSection(),
                    const SizedBox(height: 32),

                    // Inputs list
                    _buildInputLabel('Full Name'),
                    _buildInputField(
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                      hint: 'Enter your full name',
                      validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 18),

                    _buildInputLabel('Email Address'),
                    _buildInputField(
                      controller: _emailController,
                      icon: Icons.mail_outline_rounded,
                      hint: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!GetUtils.isEmail(v)) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    _buildInputLabel('Phone Number'),
                    _buildInputField(
                      controller: _phoneController,
                      icon: Icons.call_outlined,
                      hint: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),

                    _buildInputLabel('Location'),
                    _buildInputField(
                      controller: _locationController,
                      icon: Icons.location_on_outlined,
                      hint: 'Enter your location',
                    ),
                    const SizedBox(height: 28),

                    // Bento Grid Section
                    Row(
                      children: [
                        Expanded(
                          child: _buildBentoCard(
                            label: 'Language',
                            value: 'English (US)',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBentoCard(
                            label: 'Timezone',
                            value: 'EST (GMT-5)',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
          // Fixed Bottom Button Container
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Obx(() {
              final displayName = _profileController.name.value;
              final avatarUrl = _profileController.avatarUrl.value;
              final fallbackAvatar =
                  'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName.isNotEmpty ? displayName : "User")}&background=003ec7&color=fff&size=256';
              return Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(avatarUrl.isNotEmpty ? avatarUrl : fallbackAvatar),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'PROFILE IDENTITY',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15 * 12,
            color: AppColors.outline.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.05 * 11,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: AppColors.outlineVariant,
          fontSize: 15,
        ),
        prefixIcon: Icon(icon, color: AppColors.outline, size: 22),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        filled: true,
        fillColor: AppColors.surfaceContainerLow.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildBentoCard({
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.05 * 10,
              color: AppColors.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
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
      child: Obx(() {
        final isSaving = _profileController.isSaving.value;
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isSaving ? null : _handleSave,
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
            child: isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Save Changes',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.01 * 16,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      }),
    );
  }
}
