import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_token_request.freezed.dart';
part 'refresh_token_request.g.dart';

/// Request body for token refresh endpoint.
@freezed
class RefreshTokenRequest with _$RefreshTokenRequest {
  const factory RefreshTokenRequest({
    @JsonKey(name: 'refresh_token') required String refreshToken,
  }) = _RefreshTokenRequest;

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);
}
