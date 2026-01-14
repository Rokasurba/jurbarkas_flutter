import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/auth/data/models/user_model.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

/// Response model for authentication endpoints (login, register, refresh).
@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required User user,
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'token_type') required String tokenType,
    @JsonKey(name: 'expires_in') required int expiresIn,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
