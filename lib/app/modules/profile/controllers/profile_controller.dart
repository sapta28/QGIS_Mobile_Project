import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../data/services/api/auth_api_service.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
	ProfileController(this._authApiService);

	final AuthApiService _authApiService;

	final name = ''.obs;
	final email = ''.obs;
	final isLoading = false.obs;
	final errorMessage = ''.obs;

	@override
	void onInit() {
		super.onInit();
		fetchProfile();
	}

	Future<void> fetchProfile() async {
		if (isLoading.value) {
			return;
		}

		isLoading.value = true;
		errorMessage.value = '';
		try {
			final response = await _authApiService.me();
			final data = response['data'] is Map ? response['data'] : response;
			if (data is Map) {
				name.value = data['name']?.toString() ?? '';
				email.value = data['email']?.toString() ?? '';
			}
		} catch (error) {
			errorMessage.value =
					_getErrorMessage(error, 'Gagal memuat profil pengguna.');
			Get.snackbar('Profile', errorMessage.value);
		} finally {
			isLoading.value = false;
		}
	}

	Future<void> logout() async {
		try {
			await _authApiService.logout();
		} catch (_) {
			// Ignore logout errors and proceed to login screen.
		} finally {
			Get.offAllNamed(Routes.LOGIN);
		}
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
