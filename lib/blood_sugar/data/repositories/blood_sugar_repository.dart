import 'package:dio/dio.dart';
import 'package:frontend/blood_sugar/data/models/blood_sugar_reading.dart';
import 'package:frontend/blood_sugar/data/models/create_blood_sugar_request.dart';
import 'package:frontend/blood_sugar/data/models/update_blood_sugar_request.dart';
import 'package:frontend/core/core.dart';

class BloodSugarRepository {
  BloodSugarRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ApiResponse<BloodSugarReading>> createReading({
    required double glucoseLevel,
    DateTime? measuredAt,
  }) async {
    try {
      final request = CreateBloodSugarRequest(
        glucoseLevel: glucoseLevel,
        measuredAt: measuredAt,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.bloodSugar,
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => BloodSugarReading.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  Future<ApiResponse<BloodSugarReading>> updateReading({
    required int id,
    required double glucoseLevel,
  }) async {
    try {
      final request = UpdateBloodSugarRequest(
        glucoseLevel: glucoseLevel,
      );

      final response = await _apiClient.put<Map<String, dynamic>>(
        '${ApiConstants.bloodSugar}/$id',
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => BloodSugarReading.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  Future<ApiResponse<void>> deleteReading({required int id}) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiConstants.bloodSugar}/$id',
      );

      return ApiResponse.fromJson(
        response.data!,
        (_) {},
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  Future<ApiResponse<List<BloodSugarReading>>> getHistory({
    PaginationParams params = const PaginationParams(),
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.bloodSugar,
        queryParameters: params.toQueryMapOrNull(),
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => (json! as List<dynamic>)
            .map(
              (e) => BloodSugarReading.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }
}
