import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? _createStorage();

  final FlutterSecureStorage _storage;

  static FlutterSecureStorage _createStorage() {
    if (kIsWeb) {
      // Web uses localStorage which isn't truly secure, but we configure it
      // to work without encryption issues
      return const FlutterSecureStorage(
        webOptions: WebOptions(
          dbName: 'JurbarkasApp',
          publicKey: 'JurbarkasApp',
        ),
      );
    }
    return const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
  }

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _resetEmailKey = 'reset_email';
  static const _resetTokenKey = 'reset_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
      ]);
    } catch (_) {
      // Storage can fail on web, ignore silently
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (_) {
      // flutter_secure_storage can throw on web when storage is not available
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
      ]);
    } catch (_) {
      // Ignore storage errors
    }
  }

  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null;
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {
      // Ignore storage errors
    }
  }

  // Password Reset Methods
  Future<void> savePasswordResetData({
    required String email,
    String? resetToken,
  }) async {
    try {
      await _storage.write(key: _resetEmailKey, value: email);
      if (resetToken != null) {
        await _storage.write(key: _resetTokenKey, value: resetToken);
      }
    } catch (_) {
      // Ignore storage errors
    }
  }

  Future<String?> getResetEmail() async {
    try {
      return await _storage.read(key: _resetEmailKey);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getResetToken() async {
    try {
      return await _storage.read(key: _resetTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearPasswordResetData() async {
    try {
      await Future.wait([
        _storage.delete(key: _resetEmailKey),
        _storage.delete(key: _resetTokenKey),
      ]);
    } catch (_) {
      // Ignore storage errors
    }
  }
}
