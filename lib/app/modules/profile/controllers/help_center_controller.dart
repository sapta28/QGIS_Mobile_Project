import 'package:get/get.dart';

import '../../../data/services/profile_mock_service.dart';

class HelpCenterController extends GetxController {
  final _service = ProfileMockService();

  final allFaqs = <FaqModel>[].obs;
  final filteredFaqs = <FaqModel>[].obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'Semua'.obs;
  final expandedId = ''.obs;

  final categories = const ['Semua', 'Booking', 'Pembayaran', 'Materi Iklan', 'Akun'];

  @override
  void onInit() {
    super.onInit();
    allFaqs.assignAll(_service.getFaq());
    _applyFilter();

    ever(searchQuery, (_) => _applyFilter());
    ever(selectedCategory, (_) => _applyFilter());
  }

  void _applyFilter() {
    final query = searchQuery.value.toLowerCase().trim();
    final cat = selectedCategory.value;

    filteredFaqs.assignAll(allFaqs.where((faq) {
      final matchCat = cat == 'Semua' || faq.category == cat;
      final matchQuery = query.isEmpty ||
          faq.question.toLowerCase().contains(query) ||
          faq.answer.toLowerCase().contains(query);
      return matchCat && matchQuery;
    }).toList());

    // Reset expanded when filter changes
    expandedId.value = '';
  }

  void setCategory(String cat) {
    selectedCategory.value = cat;
  }

  void setSearch(String query) {
    searchQuery.value = query;
  }

  void toggleExpand(String id) {
    expandedId.value = expandedId.value == id ? '' : id;
  }
}
