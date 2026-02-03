import 'package:frontend/app/app.dart';
import 'package:frontend/bootstrap.dart';
import 'package:frontend/core/config/config.dart';

Future<void> main() async {
  const envName = String.fromEnvironment('ENV', defaultValue: 'development');
  final environment = switch (envName) {
    'production' => Environment.production,
    'staging' => Environment.staging,
    _ => Environment.development,
  };

  AppConfig.init(environment);
  await bootstrap(() => const App());
}
