import 'package:dio/dio.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/dashboard/data/models/dashboard_response.dart';

class DashboardRepository {
  DashboardRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ApiResponse<DashboardResponse>> getDashboard() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.dashboard,
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => DashboardResponse.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }
}
