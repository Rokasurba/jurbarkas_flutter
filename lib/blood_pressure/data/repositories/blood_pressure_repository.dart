import 'package:dio/dio.dart';
import 'package:frontend/blood_pressure/data/models/blood_pressure_reading.dart';
import 'package:frontend/blood_pressure/data/models/create_blood_pressure_request.dart';
import 'package:frontend/core/core.dart';

class BloodPressureRepository {
  BloodPressureRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ApiResponse<BloodPressureReading>> createReading({
    required int systolic,
    required int diastolic,
    DateTime? measuredAt,
  }) async {
    try {
      final request = CreateBloodPressureRequest(
        systolic: systolic,
        diastolic: diastolic,
        measuredAt: measuredAt,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.bloodPressure,
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => BloodPressureReading.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  Future<ApiResponse<List<BloodPressureReading>>> getHistory({
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.bloodPressure,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => (json! as List<dynamic>)
            .map(
              (e) => BloodPressureReading.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }
}
