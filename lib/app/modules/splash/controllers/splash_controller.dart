import 'dart:async';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  Timer? _redirectTimer;

  @override
  void onReady() {
    super.onReady();
    _goToOnboarding();
  }

  void _goToOnboarding() {
    _redirectTimer?.cancel();
    _redirectTimer = Timer(const Duration(milliseconds: 1800), () {
      if (Get.currentRoute == Routes.SPLASH) {
        Get.offAllNamed(Routes.ONBOARDING);
      }
    });
  }

  @override
  void onClose() {
    _redirectTimer?.cancel();
    super.onClose();
  }
}
