import 'package:get/get.dart';

import '../../../data/services/auth_dummy_api_service.dart';
import '../controllers/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthDummyApiService>(AuthDummyApiService.new);
    Get.lazyPut<RegisterController>(() => RegisterController(Get.find<AuthDummyApiService>()));
  }
}
