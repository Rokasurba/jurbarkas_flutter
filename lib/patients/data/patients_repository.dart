import 'package:dio/dio.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/patients/data/models/patient_list_item.dart';
import 'package:frontend/patients/data/models/patient_list_params.dart';

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
}
