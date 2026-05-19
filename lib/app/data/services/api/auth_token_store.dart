import 'package:get_storage/get_storage.dart';

class AuthTokenStore {
  AuthTokenStore() : _box = GetStorage();

  static const String _accessTokenKey = 'access_token';

  final GetStorage _box;

  String? get accessToken => _box.read<String>(_accessTokenKey);

  Future<void> saveAccessToken(String token) async {
    await _box.write(_accessTokenKey, token);
  }

  Future<void> clear() async {
    await _box.remove(_accessTokenKey);
  }
}
