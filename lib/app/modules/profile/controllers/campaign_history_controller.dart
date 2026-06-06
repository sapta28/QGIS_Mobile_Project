import 'package:get/get.dart';

import '../../../data/services/profile_mock_service.dart';

class CampaignHistoryController extends GetxController {
  final _service = ProfileMockService();

  final campaigns = <CampaignHistoryModel>[].obs;
  final isLoading = false.obs;
  final selectedTab = 'Semua'.obs; // 'Semua' | 'Past' | 'Expired'

  List<CampaignHistoryModel> get filtered {
    if (selectedTab.value == 'Semua') return campaigns;
    final statusMap = {'Past': 'past', 'Expired': 'expired'};
    final key = statusMap[selectedTab.value];
    return campaigns.where((c) => c.status == key).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    try {
      final result = await _service.getCampaignHistory();
      campaigns.assignAll(result);
    } catch (e) {
      // silent
    } finally {
      isLoading.value = false;
    }
  }

  void setTab(String tab) {
    selectedTab.value = tab;
  }
}
