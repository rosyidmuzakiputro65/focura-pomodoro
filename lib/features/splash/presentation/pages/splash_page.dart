import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final settingsCubit = context.read<SettingsCubit>();
    final authCubit = context.read<AuthCubit>();
    await Future.wait([
      settingsCubit.load(),
      Future<void>.delayed(const Duration(milliseconds: 900)),
    ]);
    if (!mounted) return;
    if (!settingsCubit.state.onboardingDone) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      return;
    }
    // Navigasi ke login/home ditangani listener AuthCubit di app.dart.
    await authCubit.checkSession();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 88),
            const SizedBox(height: 20),
            Text(
              s.appName,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              s.tagline,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
