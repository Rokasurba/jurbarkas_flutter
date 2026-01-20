import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_blood_sugar_request.freezed.dart';
part 'create_blood_sugar_request.g.dart';

@freezed
class CreateBloodSugarRequest with _$CreateBloodSugarRequest {
  const factory CreateBloodSugarRequest({
    @JsonKey(name: 'glucose_level') required double glucoseLevel,
    @JsonKey(name: 'measured_at') DateTime? measuredAt,
  }) = _CreateBloodSugarRequest;

  factory CreateBloodSugarRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBloodSugarRequestFromJson(json);
}
