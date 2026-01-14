import 'package:frontend/app/app.dart';
import 'package:frontend/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
