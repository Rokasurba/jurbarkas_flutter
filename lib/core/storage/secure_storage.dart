import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _resetEmailKey = 'reset_email';
  static const _resetTokenKey = 'reset_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null;
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Password Reset Methods
  Future<void> savePasswordResetData({
    required String email,
    String? resetToken,
  }) async {
    await _storage.write(key: _resetEmailKey, value: email);
    if (resetToken != null) {
      await _storage.write(key: _resetTokenKey, value: resetToken);
    }
  }

  Future<String?> getResetEmail() async {
    return _storage.read(key: _resetEmailKey);
  }

  Future<String?> getResetToken() async {
    return _storage.read(key: _resetTokenKey);
  }

  Future<void> clearPasswordResetData() async {
    await Future.wait([
      _storage.delete(key: _resetEmailKey),
      _storage.delete(key: _resetTokenKey),
    ]);
  }
}
