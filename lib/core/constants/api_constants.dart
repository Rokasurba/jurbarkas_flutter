import 'package:frontend/core/config/config.dart';

abstract class ApiConstants {
  /// Base URL loaded from environment configuration
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String user = '/auth/user';
  static const String deviceToken = '/auth/device-token';

  // Password reset endpoints
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';

  // Health data endpoints
  static const String bloodPressure = '/blood-pressure';
  static const String bmi = '/bmi';
  static const String bloodSugar = '/blood-sugar';

  // Dashboard endpoint
  static const String dashboard = '/dashboard';

  // Patients endpoint (doctor/admin only)
  static const String patients = '/patients';

  // Conversations/Chat endpoints
  static const String conversations = '/conversations';

  /// Get messages for a conversation: /conversations/{id}/messages
  static String conversationMessages(int conversationId) =>
      '/conversations/$conversationId/messages';

  /// Mark conversation as read: /conversations/{id}/read
  static String conversationRead(int conversationId) =>
      '/conversations/$conversationId/read';

  // Reminders endpoints
  static const String reminders = '/reminders';
  /// Mark reminder as read: /reminders/{id}/read
  static String reminderRead(int id) => '/reminders/$id/read';
}
