import 'package:dio/dio.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/patients/data/models/patient_health_data_params.dart';
import 'package:frontend/patients/data/models/patient_health_data_response.dart';
import 'package:frontend/patients/data/models/patient_list_item.dart';
import 'package:frontend/patients/data/models/patient_list_params.dart';
import 'package:frontend/patients/data/models/patient_profile.dart';

class PatientsRepository {
  PatientsRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ApiResponse<PatientsResponse>> getPatients({
    PatientListParams params = const PatientListParams.firstPage(),
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.patients,
        queryParameters: params.toQueryMapOrNull(),
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => PatientsResponse.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Fetch a single patient's profile by ID.
  Future<ApiResponse<PatientProfile>> getPatientById(int patientId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.patients}/$patientId',
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => PatientProfile.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Fetch all health data for a patient (doctor/admin only).
  ///
  /// Returns blood pressure, BMI, and blood sugar data in a single request.
  Future<ApiResponse<PatientHealthDataResponse>> getPatientHealthData(
    int patientId, {
    PatientHealthDataParams params = const PatientHealthDataParams.noFilter(),
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.patients}/$patientId/health-data',
        queryParameters: params.toQueryMapOrNull(),
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) =>
            PatientHealthDataResponse.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }
}
