import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:frontend/core/data/api_response.dart';
import 'package:frontend/core/utils/dio_utils.dart';
import 'package:frontend/survey/data/models/aggregated_survey_results.dart';
import 'package:frontend/survey/data/models/assigned_survey.dart';
import 'package:frontend/survey/data/models/completed_survey.dart';
import 'package:frontend/survey/data/models/doctor_survey_results.dart';
import 'package:frontend/survey/data/models/survey.dart';
import 'package:frontend/survey/data/models/survey_answer.dart';
import 'package:frontend/survey/data/models/survey_for_completion.dart';

class SurveyRepository {
  SurveyRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Doctor/Admin: Get all surveys
  Future<ApiResponse<List<Survey>>> getSurveys() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/surveys',
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) {
          final list = json! as List;
          return list
              .map((e) => Survey.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  Future<ApiResponse<List<AssignedSurvey>>> getAssignedSurveys() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/surveys/assigned',
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) {
          final list = json! as List;
          return list
              .map((e) => AssignedSurvey.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  Future<ApiResponse<SurveyForCompletion>> getSurveyForCompletion(
    int assignmentId,
  ) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/surveys/assigned/$assignmentId',
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => SurveyForCompletion.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  Future<ApiResponse<CompletedSurvey>> getCompletedSurvey(
    int assignmentId,
  ) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/surveys/assigned/$assignmentId',
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => CompletedSurvey.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  Future<ApiResponse<void>> submitSurveyAnswers(
    int assignmentId,
    List<SurveyAnswer> answers,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/surveys/assigned/$assignmentId/submit',
        data: {
          'answers': answers.map((a) => a.toJson()).toList(),
        },
      );

      return ApiResponse.fromJson(
        response.data!,
        (_) {},
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Doctor: Get surveys assigned to a specific patient
  Future<ApiResponse<List<AssignedSurvey>>> getPatientSurveys({
    required int patientId,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/surveys/patient/$patientId',
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) {
          final list = json! as List;
          return list
              .map((e) => AssignedSurvey.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Doctor: Get individual patient survey results
  Future<ApiResponse<DoctorSurveyResults>> getDoctorSurveyResults({
    required int surveyId,
    required int patientId,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/surveys/$surveyId/results/$patientId',
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => DoctorSurveyResults.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Doctor: Get aggregated survey results
  Future<ApiResponse<AggregatedSurveyResults>> getAggregatedSurveyResults({
    required int surveyId,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/surveys/$surveyId/results',
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) =>
            AggregatedSurveyResults.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Doctor: Export aggregated results as CSV
  Future<ApiResponse<Uint8List>> exportAggregatedResults({
    required int surveyId,
  }) async {
    try {
      final response = await _apiClient.get<List<int>>(
        '/surveys/$surveyId/results/export',
        options: Options(responseType: ResponseType.bytes),
      );

      return ApiResponse.success(
        data: Uint8List.fromList(response.data!),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }
}
