import 'package:flutter/material.dart';
import 'app.dart';
import 'core/bootstrap/core_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CoreDependencies.mock();
  runApp(const HorseRacingApp());
}
