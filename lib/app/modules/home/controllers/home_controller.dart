import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxInt selectedNavIndex = 0.obs;
  final RxInt selectedCampaignTab = 0.obs;

  void changeNav(int index) {
    selectedNavIndex.value = index;
  }

  void changeCampaignTab(int index) {
    selectedCampaignTab.value = index;
  }
}
