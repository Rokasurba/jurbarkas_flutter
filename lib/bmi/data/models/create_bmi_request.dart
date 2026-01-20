import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_bmi_request.freezed.dart';
part 'create_bmi_request.g.dart';

@freezed
class CreateBmiRequest with _$CreateBmiRequest {
  const factory CreateBmiRequest({
    @JsonKey(name: 'height_cm') required int heightCm,
    @JsonKey(name: 'weight_kg') required double weightKg,
    @JsonKey(name: 'measured_at') DateTime? measuredAt,
  }) = _CreateBmiRequest;

  factory CreateBmiRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBmiRequestFromJson(json);
}
