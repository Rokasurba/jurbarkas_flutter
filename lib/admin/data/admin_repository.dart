import 'package:dio/dio.dart';
import 'package:frontend/admin/data/models/activity_log.dart';
import 'package:frontend/admin/data/models/create_doctor_request.dart';
import 'package:frontend/admin/data/models/create_doctor_response.dart';
import 'package:frontend/admin/data/models/paginated_response.dart';
import 'package:frontend/admin/data/models/update_doctor_request.dart';
import 'package:frontend/admin/data/models/update_patient_request.dart';
import 'package:frontend/auth/data/models/user_model.dart';
import 'package:frontend/core/core.dart';

/// Admin endpoints for doctor management.
abstract class _AdminDoctorEndpoints {
  static const String doctors = '/admin/doctors';
  static String doctor(int id) => '/admin/doctors/$id';
  static String restoreDoctor(int id) => '/admin/doctors/$id/restore';
}

/// Admin endpoints for patient management.
abstract class _AdminPatientEndpoints {
  static String patient(int id) => '/admin/patients/$id';
  static String restorePatient(int id) => '/admin/patients/$id/restore';
}

/// Admin endpoints for activity logs.
abstract class _AdminActivityLogEndpoints {
  static const String activityLogs = '/admin/activity-logs';
  static const String exportLogs = '/admin/activity-logs/export';
}

/// Repository for admin operations (doctor management).
class AdminRepository {
  AdminRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Fetch paginated list of all doctors.
  Future<ApiResponse<PaginatedResponse<User>>> getDoctors({int page = 1}) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        _AdminDoctorEndpoints.doctors,
        queryParameters: {'page': page},
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => PaginatedResponse.fromJson(
          json! as Map<String, dynamic>,
          (item) => User.fromJson(item! as Map<String, dynamic>),
        ),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Fetch a single doctor by ID.
  Future<ApiResponse<User>> getDoctor(int id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        _AdminDoctorEndpoints.doctor(id),
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => User.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Create a new doctor account.
  Future<ApiResponse<CreateDoctorResponse>> createDoctor(
    CreateDoctorRequest request,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        _AdminDoctorEndpoints.doctors,
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => CreateDoctorResponse.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Update an existing doctor's details.
  Future<ApiResponse<User>> updateDoctor(
    int id,
    UpdateDoctorRequest request,
  ) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        _AdminDoctorEndpoints.doctor(id),
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => User.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Deactivate a doctor account (sets is_active = false).
  Future<ApiResponse<void>> deactivateDoctor(int id) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        _AdminDoctorEndpoints.doctor(id),
      );

      final success = response.data?['success'] as bool? ?? false;
      if (success) {
        return const ApiResponse.success(data: null);
      }

      return ApiResponse.error(
        message: response.data?['message'] as String? ?? 'Failed to deactivate',
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Reactivate a doctor account (sets is_active = true).
  Future<ApiResponse<User>> reactivateDoctor(int id) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        _AdminDoctorEndpoints.restoreDoctor(id),
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => User.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  // ==================== Patient Management ====================

  /// Update an existing patient's details.
  Future<ApiResponse<User>> updatePatient(
    int id,
    UpdatePatientRequest request,
  ) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        _AdminPatientEndpoints.patient(id),
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => User.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Deactivate a patient account (sets is_active = false).
  Future<ApiResponse<void>> deactivatePatient(int id) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        _AdminPatientEndpoints.patient(id),
      );

      final success = response.data?['success'] as bool? ?? false;
      if (success) {
        return const ApiResponse.success(data: null);
      }

      return ApiResponse.error(
        message: response.data?['message'] as String? ?? 'Failed to deactivate',
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Reactivate a patient account (sets is_active = true).
  Future<ApiResponse<User>> reactivatePatient(int id) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        _AdminPatientEndpoints.restorePatient(id),
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => User.fromJson(json! as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  // ==================== Activity Logs ====================

  /// Fetch paginated list of activity logs with optional filters.
  Future<ApiResponse<PaginatedResponse<ActivityLog>>> getActivityLogs({
    int page = 1,
    String? dateFrom,
    String? dateTo,
    int? userId,
    String? event,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (dateFrom != null) queryParams['date_from'] = dateFrom;
      if (dateTo != null) queryParams['date_to'] = dateTo;
      if (userId != null) queryParams['user_id'] = userId;
      if (event != null) queryParams['event'] = event;

      final response = await _apiClient.get<Map<String, dynamic>>(
        _AdminActivityLogEndpoints.activityLogs,
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) => PaginatedResponse.fromJson(
          json! as Map<String, dynamic>,
          (item) => ActivityLog.fromJson(item! as Map<String, dynamic>),
        ),
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Export activity logs as CSV with optional filters.
  /// Returns the CSV content as a string, or null on error.
  Future<String?> exportActivityLogs({
    String? dateFrom,
    String? dateTo,
    int? userId,
    String? event,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (dateFrom != null) queryParams['date_from'] = dateFrom;
      if (dateTo != null) queryParams['date_to'] = dateTo;
      if (userId != null) queryParams['user_id'] = userId;
      if (event != null) queryParams['event'] = event;

      final response = await _apiClient.get<String>(
        _AdminActivityLogEndpoints.exportLogs,
        queryParameters: queryParams,
        options: Options(responseType: ResponseType.plain),
      );

      return response.data;
    } on DioException {
      return null;
    }
  }
}
