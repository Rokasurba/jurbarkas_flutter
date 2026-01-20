import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_bmi_request.freezed.dart';
part 'update_bmi_request.g.dart';

@freezed
class UpdateBmiRequest with _$UpdateBmiRequest {
  const factory UpdateBmiRequest({
    @JsonKey(name: 'height_cm') required int heightCm,
    @JsonKey(name: 'weight_kg') required double weightKg,
  }) = _UpdateBmiRequest;

  factory UpdateBmiRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateBmiRequestFromJson(json);
}
