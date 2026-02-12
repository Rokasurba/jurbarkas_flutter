import 'package:envied/envied.dart';

part 'env.g.dart';

/// Environment configuration for Development
@Envied(path: '.env.development', useConstantCase: true)
abstract class EnvDev {
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _EnvDev.apiBaseUrl;

  @EnviedField(varName: 'APP_NAME')
  static const String appName = _EnvDev.appName;
}

/// Environment configuration for Staging
@Envied(path: '.env.staging', useConstantCase: true)
abstract class EnvStaging {
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _EnvStaging.apiBaseUrl;

  @EnviedField(varName: 'APP_NAME')
  static const String appName = _EnvStaging.appName;
}

/// Environment configuration for Production
@Envied(path: '.env.production', useConstantCase: true)
abstract class EnvProd {
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _EnvProd.apiBaseUrl;

  @EnviedField(varName: 'APP_NAME')
  static const String appName = _EnvProd.appName;
}

/// Environment types
enum Environment { development, staging, production }

/// Runtime environment configuration
class AppConfig {
  AppConfig._();

  static late Environment _environment;
  static late String _apiBaseUrl;
  static late String _appName;

  static Environment get environment => _environment;
  static String get apiBaseUrl => _apiBaseUrl;
  static String get appName => _appName;

  static void init(Environment env) {
    _environment = env;
    switch (env) {
      case Environment.development:
        _apiBaseUrl = EnvDev.apiBaseUrl;
        _appName = EnvDev.appName;
      case Environment.staging:
        _apiBaseUrl = EnvStaging.apiBaseUrl;
        _appName = EnvStaging.appName;
      case Environment.production:
        _apiBaseUrl = EnvProd.apiBaseUrl;
        _appName = EnvProd.appName;
    }
  }

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;
}
