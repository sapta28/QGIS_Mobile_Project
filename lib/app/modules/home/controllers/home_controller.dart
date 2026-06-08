import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../data/services/api/user_api_service.dart';
import '../../../../models/models.dart';

class HomeController extends GetxController {
  HomeController(this._userApiService);

  final UserApiService _userApiService;

  final RxInt selectedNavIndex = 0.obs;
  final RxInt selectedCampaignTab = 0.obs;

  final activeAdsCount = 0.obs;
  final pendingInvoicesCount = 0.obs;
  final isLoadingDashboard = false.obs;
  final errorMessage = ''.obs;
  final campaignBundles = <CampaignBundleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardSummary();
    loadDummyCampaignBundles();
  }

  Future<void> fetchDashboardSummary() async {
    if (isLoadingDashboard.value) {
      return;
    }

    isLoadingDashboard.value = true;
    errorMessage.value = '';
    try {
      final response = await _userApiService.getDashboardSummary();
      final data = response['data'];
      if (data is Map) {
        activeAdsCount.value = _toInt(data['active_ads_count']);
        pendingInvoicesCount.value = _toInt(data['pending_invoices_count']);
      }
    } catch (error) {
      errorMessage.value =
          _getErrorMessage(error, 'Gagal memuat ringkasan dashboard.');
      // Silent fail - show default values
    } finally {
      isLoadingDashboard.value = false;
    }
  }

  void changeNav(int index) {
    selectedNavIndex.value = index;
  }

  void changeCampaignTab(int index) {
    selectedCampaignTab.value = index;
  }

  void loadDummyCampaignBundles() {
    const data = [
      CampaignBundleModel(
        title: 'Dominate CBD',
        subtitle: '3 Strategic Videotrons in Business Center',
        imageUrl:
            'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?auto=format&fit=crop&w=600&q=80',
      ),
      CampaignBundleModel(
        title: 'Holiday Special',
        subtitle: 'Highway & Rest Area Dominance',
        imageUrl:
            'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=600&q=80',
      ),
      CampaignBundleModel(
        title: 'Airport Takeover',
        subtitle: 'All digital screens in Terminal 3',
        imageUrl:
            'https://images.unsplash.com/photo-1530521954074-e64f6810b32d?auto=format&fit=crop&w=600&q=80',
      ),
    ];

    campaignBundles.assignAll(data);
  }

  int _toInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _getErrorMessage(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    }
    return fallback;
  }
}
