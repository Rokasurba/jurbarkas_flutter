abstract class ApiConstants {
  static const String baseUrl = 'http://localhost:8000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String user = '/auth/user';
}
