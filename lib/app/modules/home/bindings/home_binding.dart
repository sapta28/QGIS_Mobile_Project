import 'package:get/get.dart';

import '../../../data/services/api/api_client.dart';
import '../../../data/services/api/auth_token_store.dart';
import '../../../data/services/api/auth_api_service.dart';
import '../../../data/services/api/user_api_service.dart';
import '../../explore/controllers/explore_controller.dart';
import '../controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/controllers/payment_methods_controller.dart';
import '../../profile/controllers/notifications_controller.dart';
import '../../profile/controllers/saved_billboards_controller.dart';
import '../../profile/controllers/campaign_history_controller.dart';
import '../../profile/controllers/help_center_controller.dart';

class HomeBinding extends Bindings {
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
    if (!Get.isRegistered<AuthApiService>()) {
      Get.lazyPut<AuthApiService>(
        () => AuthApiService(
          Get.find<ApiClient>(),
          Get.find<AuthTokenStore>(),
        ),
      );
    }
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<UserApiService>()),
    );
    Get.lazyPut<ExploreController>(
      () => ExploreController(Get.find<UserApiService>()),
    );

    // Profile & sub-controllers (fenix: true agar tidak hilang saat navigasi)
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(
        () => ProfileController(
          Get.find<AuthApiService>(),
          Get.find<AuthTokenStore>(),
        ),
        fenix: true,
      );
    }
    Get.lazyPut<PaymentMethodsController>(
      PaymentMethodsController.new,
      fenix: true,
    );
    Get.lazyPut<NotificationsController>(
      NotificationsController.new,
      fenix: true,
    );
    Get.lazyPut<SavedBillboardsController>(
      SavedBillboardsController.new,
      fenix: true,
    );
    Get.lazyPut<CampaignHistoryController>(
      CampaignHistoryController.new,
      fenix: true,
    );
    Get.lazyPut<HelpCenterController>(
      HelpCenterController.new,
      fenix: true,
    );
  }
}
