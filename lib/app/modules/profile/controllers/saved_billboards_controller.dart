import 'package:get/get.dart';

import '../../../data/services/profile_mock_service.dart';

class SavedBillboardsController extends GetxController {
  final _service = ProfileMockService();

  final savedList = <SavedBillboardModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSaved();
  }

  Future<void> fetchSaved() async {
    isLoading.value = true;
    try {
      final result = await _service.getSavedBillboards();
      savedList.assignAll(result);
    } catch (e) {
      // silent
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFavorite(String id) async {
    try {
      await _service.removeSavedBillboard(id);
      savedList.removeWhere((b) => b.id == id);
      Get.snackbar(
        'Dihapus',
        'Billboard dihapus dari favorit.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus favorit.');
    }
  }
}
