import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:tech_comp_app/theme/appcolors.dart';

void main() async {
  // Required so native plugins (like SharedPreferences) work during app startup
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tech Compare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const SplashScreen(),
    );
  }
}