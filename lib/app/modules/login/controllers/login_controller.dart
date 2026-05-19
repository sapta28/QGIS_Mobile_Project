import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/api/auth_api_service.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  LoginController(this._authApiService);

  final AuthApiService _authApiService;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final rememberMe = true.obs;
  final infoMessage = ''.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> submitLogin() async {
    if (!(formKey.currentState?.validate() ?? false) || isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final result = await _authApiService.login(
        email: emailController.text,
        password: passwordController.text,
      );

      final message = result['message']?.toString() ?? 'Login berhasil.';
      Get.snackbar('Login berhasil', message);
      Get.offAllNamed(Routes.HOME);
    } catch (error) {
      final message = _getErrorMessage(error, 'Login gagal. Coba lagi.');
      infoMessage.value = message;
      Get.snackbar('Login gagal', message);
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
    if (password.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  String _getErrorMessage(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            return first.first.toString();
          }
        }
      }
    }
    return fallback;
  }
}