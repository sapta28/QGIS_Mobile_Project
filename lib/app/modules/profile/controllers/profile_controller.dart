import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/services/api/auth_api_service.dart';
import '../../../data/services/api/auth_token_store.dart';
import '../../../routes/app_pages.dart';
import '../../../../models/models.dart';

class ProfileController extends GetxController {
	ProfileController(this._authApiService, this._tokenStore);

	final AuthApiService _authApiService;
	final AuthTokenStore _tokenStore;
	final _storage = GetStorage();

	final name = ''.obs;
	final email = ''.obs;
	final phone = ''.obs;
	final role = ''.obs;
	final avatarUrl = ''.obs;
	final companyId = ''.obs;
	final userId = ''.obs;
	final isLoading = false.obs;
	final isSaving = false.obs;
	final errorMessage = ''.obs;
	final isNotificationsEnabled = true.obs;
	final savedBillboards = <BillboardModel>[].obs;

	@override
	void onInit() {
		super.onInit();
		isNotificationsEnabled.value = _storage.read('is_notifications_enabled') ?? true;
		loadSavedBillboards();
		fetchProfile();
	}

	void loadSavedBillboards() {
		try {
			final List<dynamic>? rawList = _storage.read<List<dynamic>>('saved_billboards');
			if (rawList != null) {
				savedBillboards.value = rawList
						.map((item) => BillboardModel.fromJson(Map<String, dynamic>.from(item)))
						.toList();
			} else {
				savedBillboards.clear();
			}
		} catch (e) {
			savedBillboards.clear();
		}
	}

	bool isBillboardSaved(String id) {
		return savedBillboards.any((b) => b.id == id);
	}

	void toggleSaveBillboard(BillboardModel billboard) {
		if (isBillboardSaved(billboard.id)) {
			savedBillboards.removeWhere((b) => b.id == billboard.id);
		} else {
			savedBillboards.add(billboard);
		}
		_storage.write('saved_billboards', savedBillboards.map((b) => b.toJson()).toList());
	}

	void toggleNotifications(bool value) {
		isNotificationsEnabled.value = value;
		_storage.write('is_notifications_enabled', value);
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
				phone.value = data['phone']?.toString() ?? _storage.read('local_phone') ?? '';
				// role.value = data['role']?.toString() ?? '';
				avatarUrl.value = _storage.read('local_avatar_path') ?? data['avatar_url']?.toString() ?? '';
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

	void updateLocalAvatar(String path) {
		avatarUrl.value = path;
		_storage.write('local_avatar_path', path);
	}

	Future<bool> updateProfile({
		required String name,
		required String email,
		String? phone,
	}) async {
		if (isSaving.value) {
			return false;
		}

		isSaving.value = true;
		try {
			final response = await _authApiService.updateProfile(
				name: name,
				email: email,
				phone: phone,
			);
			final data = response['data'] is Map ? response['data'] : response;
			if (data is Map) {
				this.name.value = data['name']?.toString() ?? this.name.value;
				this.email.value = data['email']?.toString() ?? this.email.value;
				if (phone != null) {
					this.phone.value = data['phone']?.toString() ?? phone;
				}
				avatarUrl.value = _storage.read('local_avatar_path') ?? data['avatar_url']?.toString() ?? avatarUrl.value;
				role.value = data['role']?.toString() ?? role.value;
				companyId.value = data['company_id']?.toString() ?? companyId.value;
			} else {
				this.name.value = name;
				this.email.value = email;
				if (phone != null) {
					this.phone.value = phone;
				}
			}
			if (phone != null) {
				_storage.write('local_phone', phone);
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
