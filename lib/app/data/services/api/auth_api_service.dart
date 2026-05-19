import 'package:dio/dio.dart';

import 'api.dart';
import 'api_client.dart';
import 'auth_token_store.dart';

class AuthApiService {
  AuthApiService(this._client, this._tokenStore);

  final ApiClient _client;
  final AuthTokenStore _tokenStore;

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String companyName,
    required String nib,
  }) async {
    final response = await _client.post(
      ApiEndpoints.userRegister,
      data: {
        'email': email,
        'password': password,
        'company_name': companyName,
        'nib': nib,
      },
    );

    final data = _asMap(response.data);
    await _saveTokenIfAvailable(data);
    return data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiEndpoints.userLogin,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = _asMap(response.data);
    await _saveTokenIfAvailable(data);
    return data;
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _client.get(ApiEndpoints.userMe);
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> logout() async {
    final response = await _client.post(ApiEndpoints.userLogout);
    await _tokenStore.clear();
    return _asMap(response.data);
  }

  Future<void> _saveTokenIfAvailable(Map<String, dynamic> data) async {
    final token = data['access_token']?.toString();
    if (token != null && token.isNotEmpty) {
      await _tokenStore.saveAccessToken(token);
    }
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{'data': data};
  }
}
