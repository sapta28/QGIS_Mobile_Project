import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../data/services/api/auth_token_store.dart';
import 'app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Cari instance AuthTokenStore yang sudah terdaftar
    final tokenStore = Get.find<AuthTokenStore>();
    final token = tokenStore.accessToken;

    // Jika token kosong atau null, paksa redirect ke halaman LOGIN
    if (token == null || token.isEmpty) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    
    // Izinkan akses jika token valid
    return null;
  }
}
