import 'package:frontend/app/app.dart';
import 'package:frontend/bootstrap.dart';
import 'package:frontend/core/config/config.dart';

Future<void> main() async {
  AppConfig.init(Environment.production);
  await bootstrap(() => const App());
}
