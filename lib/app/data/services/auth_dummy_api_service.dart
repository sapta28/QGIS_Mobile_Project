class DummyLoginPrefill {
  DummyLoginPrefill({
    required this.defaultEmail,
    required this.defaultPassword,
    required this.hint,
  });

  final String defaultEmail;
  final String defaultPassword;
  final String hint;
}

class DummyLoginResult {
  DummyLoginResult({
    required this.success,
    required this.message,
    this.token,
  });

  final bool success;
  final String message;
  final String? token;
}

class DummyRegisterResult {
  DummyRegisterResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;
}

class AuthDummyApiService {
  static const _dummyEmail = 'demo@sig.id';
  static const _dummyPassword = '12345678';

  Future<DummyLoginPrefill> getLoginPrefill() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    return DummyLoginPrefill(
      defaultEmail: _dummyEmail,
      defaultPassword: _dummyPassword,
      hint: 'Gunakan akun demo untuk sementara sampai backend siap.',
    );
  }

  Future<DummyLoginResult> postLogin({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final isValidCredential =
        email.trim().toLowerCase() == _dummyEmail && password == _dummyPassword;

    if (!isValidCredential) {
      return DummyLoginResult(
        success: false,
        message: 'Email atau password dummy tidak cocok.',
      );
    }

    return DummyLoginResult(
      success: true,
      message: 'Login dummy berhasil.',
      token: 'dummy-token-2026',
    );
  }

  Future<DummyRegisterResult> postRegister({
    required String emailOrNib,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (emailOrNib.trim().toLowerCase() == _dummyEmail) {
      return DummyRegisterResult(
        success: false,
        message: 'Akun perusahaan ini sudah terdaftar.',
      );
    }

    if (password.length < 8) {
      return DummyRegisterResult(
        success: false,
        message: 'Kata sandi minimal 8 karakter.',
      );
    }

    return DummyRegisterResult(
      success: true,
      message: 'Registrasi dummy berhasil. Silakan login.',
    );
  }
}