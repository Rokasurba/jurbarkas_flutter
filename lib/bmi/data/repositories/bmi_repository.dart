import 'package:dio/dio.dart';
import 'package:frontend/bmi/data/models/bmi_measurement.dart';
import 'package:frontend/bmi/data/models/create_bmi_request.dart';
import 'package:frontend/core/core.dart';

class BmiRepository {
  BmiRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ApiResponse<BmiMeasurement>> createMeasurement({
    required int heightCm,
    required double weightKg,
    required DateTime measuredAt,
  }) async {
    try {
      final request = CreateBmiRequest(
        heightCm: heightCm,
        weightKg: weightKg,
        measuredAt: measuredAt,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.bmi,
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => BmiMeasurement.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  Future<ApiResponse<void>> deleteMeasurement({required int id}) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiConstants.bmi}/$id',
      );

      return ApiResponse.fromJson(
        response.data!,
        (_) {},
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  Future<ApiResponse<List<BmiMeasurement>>> getHistory({
    PaginationParams params = const PaginationParams(),
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.bmi,
        queryParameters: params.toQueryMapOrNull(),
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => (json! as List<dynamic>)
            .map(
              (e) => BmiMeasurement.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }
}
