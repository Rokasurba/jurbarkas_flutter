import 'package:dio/dio.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/patients/data/models/patient_list_item.dart';

class PatientsRepository {
  PatientsRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ApiResponse<PatientsResponse>> getPatients({
    int limit = 20,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (offset != null && offset > 0) {
        queryParams['offset'] = offset;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.patients,
        queryParameters: queryParams,
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
