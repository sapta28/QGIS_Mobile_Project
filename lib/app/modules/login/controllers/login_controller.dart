import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_dummy_api_service.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  LoginController(this._authDummyApiService);

  final AuthDummyApiService _authDummyApiService;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isFetchingDummy = false.obs;
  final isPasswordHidden = true.obs;
  final rememberMe = true.obs;
  final infoMessage = 'Tekan "Ambil Data Dummy (GET)" untuk prefill akun demo.'.obs;

  @override
  void onInit() {
    super.onInit();
    getDummyCredential();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> getDummyCredential() async {
    if (isFetchingDummy.value) {
      return;
    }

    isFetchingDummy.value = true;
    try {
      final prefill = await _authDummyApiService.getLoginPrefill();
      emailController.text = prefill.defaultEmail;
      passwordController.text = prefill.defaultPassword;
      infoMessage.value = prefill.hint;
      Get.snackbar('Dummy GET', 'Data dummy berhasil diambil.');
    } catch (_) {
      infoMessage.value = 'Gagal mengambil data dummy.';
      Get.snackbar('Dummy GET', 'Terjadi kesalahan saat ambil data dummy.');
    } finally {
      isFetchingDummy.value = false;
    }
  }

  Future<void> submitLogin() async {
    if (!(formKey.currentState?.validate() ?? false) || isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final result = await _authDummyApiService.postLogin(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!result.success) {
        Get.snackbar('Login gagal', result.message);
        return;
      }

      Get.snackbar('Login berhasil', result.message);
      Get.offAllNamed(Routes.HOME);
    } catch (_) {
      Get.snackbar('Login gagal', 'Terjadi kesalahan saat login dummy.');
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void onForgotPassword() {
    Get.snackbar('Informasi', 'Fitur lupa kata sandi belum tersedia.');
  }

  void onBiometricLogin() {
    Get.snackbar('Informasi', 'Login biometrik masih dummy.');
  }

  void onRegisterCompany() {
    Get.toNamed(Routes.REGISTER);
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  String? validateEmail(String? value) {
    final emailOrNib = value?.trim() ?? '';
    if (emailOrNib.isEmpty) {
      return 'Email perusahaan / NIB wajib diisi';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password wajib diisi';
    }
    if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }
}