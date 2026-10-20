import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      // Page Up/Down inside an empty single-line text field trips a framework
      // assertion (editable.dart `isValid`). None of our fields are
      // multi-line, so let those keys skip text fields and scroll the page.
      builder: (context, child) => Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.pageUp):
              DoNothingAndStopPropagationTextIntent(),
          SingleActivator(LogicalKeyboardKey.pageDown):
              DoNothingAndStopPropagationTextIntent(),
        },
        child: child!,
      ),
      home: session == null
          ? LoginScreen(authService: authService)
          : HomeScreen(authService: authService, user: session.user),
    );
  }
}
