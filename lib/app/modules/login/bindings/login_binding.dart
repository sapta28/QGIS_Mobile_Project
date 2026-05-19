import 'package:get/get.dart';

import '../../../data/services/api/api_client.dart';
import '../../../data/services/api/auth_api_service.dart';
import '../../../data/services/api/auth_token_store.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthTokenStore>(AuthTokenStore.new);
    Get.lazyPut<ApiClient>(() => ApiClient(Get.find<AuthTokenStore>()));
    Get.lazyPut<AuthApiService>(
      () => AuthApiService(
        Get.find<ApiClient>(),
        Get.find<AuthTokenStore>(),
      ),
    );
    Get.lazyPut<LoginController>(
      () => LoginController(Get.find<AuthApiService>()),
    );
  }
}