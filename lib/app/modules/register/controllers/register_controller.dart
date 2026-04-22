import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_dummy_api_service.dart';
import '../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  RegisterController(this._authDummyApiService);

  final AuthDummyApiService _authDummyApiService;

  final formKey = GlobalKey<FormState>();
  final emailOrNibController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    emailOrNibController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> submitRegister() async {
    if (!(formKey.currentState?.validate() ?? false) || isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final result = await _authDummyApiService.postRegister(
        emailOrNib: emailOrNibController.text,
        password: passwordController.text,
      );

      if (!result.success) {
        Get.snackbar('Registrasi gagal', result.message);
        return;
      }

      Get.snackbar('Registrasi berhasil', result.message);
      Get.offAllNamed(Routes.LOGIN);
    } catch (_) {
      Get.snackbar('Registrasi gagal', 'Terjadi kesalahan saat registrasi dummy.');
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.offAllNamed(Routes.LOGIN);
  }

  String? validateEmailOrNib(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Email perusahaan / NIB wajib diisi';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Kata sandi wajib diisi';
    }
    if (password.length < 8) {
      return 'Kata sandi minimal 8 karakter';
    }
    return null;
  }
}
