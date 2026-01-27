import 'package:dio/dio.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/reminders/data/models/reminder.dart';
import 'package:frontend/reminders/data/models/send_reminder_request.dart';

class RemindersRepository {
  RemindersRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Gets all reminders for the authenticated patient.
  Future<ApiResponse<List<Reminder>>> getReminders() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.reminders,
      );

      return ApiResponse.fromJson(
        response.data!,
        (json) {
          final list = json! as List<dynamic>;
          return list
              .map(
                (item) => Reminder.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        },
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Sends a reminder to a patient (doctor only).
  Future<ApiResponse<void>> sendReminder(SendReminderRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.reminders,
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data!,
        (_) {},
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }

  /// Marks a reminder as read.
  Future<ApiResponse<void>> markAsRead(int reminderId) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiConstants.reminderRead(reminderId),
      );

      return ApiResponse.fromJson(
        response.data!,
        (_) {},
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: extractDioErrorMessage(e));
    }
  }
}
