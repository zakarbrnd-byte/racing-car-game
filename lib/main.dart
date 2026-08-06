import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/car_selection_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const RacingCarApp());
}

class RacingCarApp extends StatelessWidget {
  const RacingCarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lane Rush',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const CarSelectionScreen(),
    );
  }
}
