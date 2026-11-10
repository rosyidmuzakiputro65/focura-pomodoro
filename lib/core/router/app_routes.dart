import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_shell.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/tasks/domain/entities/focus_task.dart';
import '../../features/tasks/presentation/pages/task_form_page.dart';

/// Daftar nama route dan pembuatnya (navigasi terpusat).
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String taskForm = '/task-form';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      splash => const SplashPage(),
      onboarding => const OnboardingPage(),
      login => const LoginPage(),
      register => const RegisterPage(),
      home => const HomeShell(),
      taskForm => TaskFormPage(task: settings.arguments as FocusTask?),
      _ => const SplashPage(),
    };
    return MaterialPageRoute<dynamic>(builder: (_) => page, settings: settings);
  }
}
