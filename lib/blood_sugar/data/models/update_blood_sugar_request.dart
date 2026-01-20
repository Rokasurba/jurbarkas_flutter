import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_blood_sugar_request.freezed.dart';
part 'update_blood_sugar_request.g.dart';

@freezed
class UpdateBloodSugarRequest with _$UpdateBloodSugarRequest {
  const factory UpdateBloodSugarRequest({
    @JsonKey(name: 'glucose_level') required double glucoseLevel,
  }) = _UpdateBloodSugarRequest;

  factory UpdateBloodSugarRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateBloodSugarRequestFromJson(json);
}
