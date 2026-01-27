import 'package:freezed_annotation/freezed_annotation.dart';

part 'mark_read_request.freezed.dart';
part 'mark_read_request.g.dart';

@freezed
class MarkReadRequest with _$MarkReadRequest {
  const factory MarkReadRequest({
    @JsonKey(name: 'last_read_id') required int lastReadId,
  }) = _MarkReadRequest;

  factory MarkReadRequest.fromJson(Map<String, dynamic> json) =>
      _$MarkReadRequestFromJson(json);
}
