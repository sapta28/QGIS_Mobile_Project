import 'package:get/get.dart';

import '../../../data/services/profile_mock_service.dart';

class PaymentMethodsController extends GetxController {
  final _service = ProfileMockService();

  final methods = <PaymentMethodModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMethods();
  }

  Future<void> fetchMethods() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _service.getPaymentMethods();
      methods.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Gagal memuat metode pembayaran.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMethod(PaymentMethodModel method) async {
    isSaving.value = true;
    try {
      await _service.addPaymentMethod(method);
      await fetchMethods();
      Get.snackbar(
        'Berhasil',
        'Metode pembayaran berhasil ditambahkan.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan metode pembayaran.');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteMethod(String id) async {
    try {
      await _service.deletePaymentMethod(id);
      methods.removeWhere((m) => m.id == id);
      Get.snackbar(
        'Berhasil',
        'Metode pembayaran dihapus.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus metode pembayaran.');
    }
  }

  Future<void> setDefault(String id) async {
    try {
      await _service.setDefaultPaymentMethod(id);
      for (final m in methods) {
        m.isDefault = m.id == id;
      }
      methods.refresh();
      Get.snackbar(
        'Berhasil',
        'Metode pembayaran utama diperbarui.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengatur metode utama.');
    }
  }
}
