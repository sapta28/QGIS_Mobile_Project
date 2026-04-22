import 'package:get/get.dart';

import '../../../data/services/auth_dummy_api_service.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthDummyApiService>(
      AuthDummyApiService.new,
    );
    Get.lazyPut<LoginController>(
      () => LoginController(Get.find<AuthDummyApiService>()),
    );
  }
}