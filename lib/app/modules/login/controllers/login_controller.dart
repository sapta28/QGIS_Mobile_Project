import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../data/services/api/auth_api_service.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  LoginController(this._authApiService);

  final AuthApiService _authApiService;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '573957690170-2f2oqs3him5va5nvv4mkvohneksmv34n.apps.googleusercontent.com'
        : '573957690170-s0rft8had6ogf68v2eu4q42tu96jhq4p.apps.googleusercontent.com',
    serverClientId: kIsWeb
        ? null
        : '573957690170-s0rft8had6ogf68v2eu4q42tu96jhq4p.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

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
      FocusManager.instance.primaryFocus?.unfocus();
      Get.offAllNamed(Routes.HOME);
    } catch (error) {
      final message = _getErrorMessage(error, 'Login gagal. Coba lagi.');
      infoMessage.value = message;
      Get.snackbar('Login gagal', message);
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void onForgotPassword() {
    Get.snackbar('Informasi', 'Fitur lupa kata sandi belum tersedia.');
  }

  Future<void> onBiometricLogin() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken != null || accessToken != null) {
        final result = await _authApiService.loginWithGoogle(
            idToken: idToken, accessToken: accessToken);
        final message = result['message']?.toString() ?? 'Login Google berhasil.';
        Get.snackbar('Login berhasil', message);
        FocusManager.instance.primaryFocus?.unfocus();
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar('Login gagal', 'Gagal mendapatkan token otentikasi Google.');
      }
    } catch (error, stackTrace) {
      debugPrint('Google Login Exception: $error');
      debugPrint('Google Login StackTrace: $stackTrace');
      final message = _getErrorMessage(error, 'Login Google gagal. Coba lagi.');
      infoMessage.value = message;
      Get.snackbar('Login gagal', message);
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> onRegisterCompany() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await Get.toNamed(Routes.REGISTER);
    if (result is String && result.trim().isNotEmpty) {
      Get.snackbar('Registrasi berhasil', result);
    }
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