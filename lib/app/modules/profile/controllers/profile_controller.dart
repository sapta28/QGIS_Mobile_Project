import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../data/services/api/auth_api_service.dart';
import '../../../data/services/api/auth_token_store.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
	ProfileController(this._authApiService, this._tokenStore);

	final AuthApiService _authApiService;
	final AuthTokenStore _tokenStore;

	final name = ''.obs;
	final email = ''.obs;
	final role = ''.obs;
	final avatarUrl = ''.obs;
	final companyId = ''.obs;
	final userId = ''.obs;
	final isLoading = false.obs;
	final isSaving = false.obs;
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
				// userId.value = data['id']?.toString() ?? '';
				name.value = data['name']?.toString() ?? '';
				email.value = data['email']?.toString() ?? '';
				// role.value = data['role']?.toString() ?? '';
				// avatarUrl.value = data['avatar_url']?.toString() ?? '';
				// companyId.value = data['company_id']?.toString() ?? '';
			}
		} catch (error) {
			errorMessage.value =
					_getErrorMessage(error, 'Gagal memuat profil pengguna.');
			Get.snackbar('Profile', errorMessage.value);
		} finally {
			isLoading.value = false;
		}
	}

	Future<bool> updateProfile({
		required String name,
		required String email,
	}) async {
		if (isSaving.value) {
			return false;
		}

		isSaving.value = true;
		try {
			final response = await _authApiService.updateProfile(
				name: name,
				email: email,
			);
			final data = response['data'] is Map ? response['data'] : response;
			if (data is Map) {
				this.name.value = data['name']?.toString() ?? this.name.value;
				this.email.value = data['email']?.toString() ?? this.email.value;
				role.value = data['role']?.toString() ?? role.value;
				avatarUrl.value =
						data['avatar_url']?.toString() ?? avatarUrl.value;
				companyId.value =
						data['company_id']?.toString() ?? companyId.value;
			}
			Get.snackbar('Profile', 'Profil berhasil diperbarui.');
			return true;
		} catch (error) {
			final message =
					_getErrorMessage(error, 'Gagal memperbarui profil pengguna.');
			Get.snackbar('Profile', message);
			return false;
		} finally {
			isSaving.value = false;
		}
	}

	Future<void> logout() async {
		try {
			await _authApiService.logout();
		} catch (_) {
			// Ignore logout errors and proceed to login screen.
		} finally {
			await _tokenStore.clear();
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
