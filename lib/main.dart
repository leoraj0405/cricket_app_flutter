import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.restoreSession();
  runApp(CricketApp(authService: authService));
}

class CricketApp extends StatelessWidget {
  const CricketApp({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    final session = authService.session;

    return MaterialApp(
      title: 'CCCHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: session == null
          ? LoginScreen(authService: authService)
          : HomeScreen(authService: authService, user: session.user),
    );
  }
}
