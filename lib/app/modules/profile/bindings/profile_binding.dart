import 'package:get/get.dart';

import '../../../data/services/api/api_client.dart';
import '../../../data/services/api/auth_api_service.dart';
import '../../../data/services/api/auth_token_store.dart';
import '../controllers/profile_controller.dart';
import '../controllers/payment_methods_controller.dart';
import '../controllers/notifications_controller.dart';
import '../controllers/saved_billboards_controller.dart';
import '../controllers/campaign_history_controller.dart';
import '../controllers/help_center_controller.dart';

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

    // Main profile controller
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<AuthApiService>(),
        Get.find<AuthTokenStore>(),
      ),
    );

    // Sub-feature controllers
    Get.lazyPut<PaymentMethodsController>(PaymentMethodsController.new);
    Get.lazyPut<NotificationsController>(NotificationsController.new);
    Get.lazyPut<SavedBillboardsController>(SavedBillboardsController.new);
    Get.lazyPut<CampaignHistoryController>(CampaignHistoryController.new);
    Get.lazyPut<HelpCenterController>(HelpCenterController.new);
  }
}
