import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend/blood_pressure/data/models/blood_pressure_reading.dart';
import 'package:frontend/blood_sugar/data/models/blood_sugar_reading.dart';
import 'package:frontend/bmi/data/models/bmi_measurement.dart';
import 'package:frontend/dashboard/data/models/user_profile.dart';

part 'dashboard_response.freezed.dart';
part 'dashboard_response.g.dart';

@freezed
class DashboardResponse with _$DashboardResponse {
  const factory DashboardResponse({
    required UserProfile user,
    @JsonKey(name: 'latest_blood_pressure')
    BloodPressureReading? latestBloodPressure,
    @JsonKey(name: 'latest_bmi') BmiMeasurement? latestBmi,
    @JsonKey(name: 'latest_blood_sugar') BloodSugarReading? latestBloodSugar,
  }) = _DashboardResponse;

  factory DashboardResponse.fromJson(Map<String, dynamic> json) =>
      _$DashboardResponseFromJson(json);
}
