import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/api/auth_api_service.dart';
import '../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  RegisterController(this._authApiService);

  final AuthApiService _authApiService;

  final formKey = GlobalKey<FormState>();
  final emailOrNibController = TextEditingController();
  final companyNameController = TextEditingController();
  final nibController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    emailOrNibController.dispose();
    companyNameController.dispose();
    nibController.dispose();
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
      final result = await _authApiService.register(
        email: emailOrNibController.text,
        password: passwordController.text,
        companyName: companyNameController.text,
        nib: nibController.text,
      );

      final message = result['message']?.toString() ?? 'Registrasi berhasil.';
      Get.snackbar('Registrasi berhasil', message);
      Get.offAllNamed(Routes.LOGIN);
    } catch (error) {
      final message = _getErrorMessage(error, 'Registrasi gagal. Coba lagi.');
      Get.snackbar('Registrasi gagal', message);
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
      return 'Email perusahaan wajib diisi';
    }
    return null;
  }

  String? validateCompanyName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Nama perusahaan wajib diisi';
    }
    return null;
  }

  String? validateNib(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'NIB wajib diisi';
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
