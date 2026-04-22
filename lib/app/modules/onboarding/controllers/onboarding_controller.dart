import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  final currentIndex = 0.obs;

  void goNext() {
    Get.toNamed(Routes.LOGIN);
  }
}
