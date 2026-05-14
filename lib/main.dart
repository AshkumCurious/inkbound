import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'themes/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const InkboundApp());
}

class InkboundApp extends StatelessWidget {
  const InkboundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inkbound',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const OnboardingScreen(),
    );
  }
}
