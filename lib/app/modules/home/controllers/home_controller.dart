import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../data/services/api/user_api_service.dart';

class HomeController extends GetxController {
  HomeController(this._userApiService);

  final UserApiService _userApiService;

  final RxInt selectedNavIndex = 0.obs;
  final RxInt selectedCampaignTab = 0.obs;

  final activeAdsCount = 0.obs;
  final pendingInvoicesCount = 0.obs;
  final isLoadingDashboard = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardSummary();
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
