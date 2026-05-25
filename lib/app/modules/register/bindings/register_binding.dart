import 'package:get/get.dart';

import '../../../data/services/api/api_client.dart';
import '../../../data/services/api/auth_api_service.dart';
import '../../../data/services/api/auth_token_store.dart';
import '../controllers/register_controller.dart';

class RegisterBinding extends Bindings {
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
    Get.lazyPut<RegisterController>(
      () => RegisterController(Get.find<AuthApiService>()),
    );
  }
}
