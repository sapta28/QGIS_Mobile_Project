import 'package:get/get.dart';

import '../../../data/services/api/api_client.dart';
import '../../../data/services/api/auth_api_service.dart';
import '../../../data/services/api/auth_token_store.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthTokenStore>()) {
      Get.lazyPut<AuthTokenStore>(AuthTokenStore.new);
    }
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(Get.find<AuthTokenStore>()));
    }
    if (!Get.isRegistered<AuthApiService>()) {
      Get.lazyPut<AuthApiService>(
        () => AuthApiService(
          Get.find<ApiClient>(),
          Get.find<AuthTokenStore>(),
        ),
      );
    }
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<AuthApiService>(),
        Get.find<AuthTokenStore>(),
      ),
    );
  }
}
