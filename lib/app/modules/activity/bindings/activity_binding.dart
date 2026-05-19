import 'package:get/get.dart';

import '../../../data/services/api/api_client.dart';
import '../../../data/services/api/auth_token_store.dart';
import '../../../data/services/api/user_api_service.dart';
import '../controllers/activity_controller.dart';

class ActivityBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthTokenStore>()) {
      Get.lazyPut<AuthTokenStore>(AuthTokenStore.new);
    }
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(Get.find<AuthTokenStore>()));
    }
    Get.lazyPut<UserApiService>(
      () => UserApiService(Get.find<ApiClient>()),
    );
    Get.lazyPut<ActivityController>(
      () => ActivityController(
        Get.find<UserApiService>(),
        Get.find<AuthTokenStore>(),
      ),
    );
  }
}
