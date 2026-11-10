import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/language_button.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../cubit/onboarding_cubit.dart';

class _OnboardingItem {
  const _OnboardingItem(this.icon, this.color, this.title, this.message);

  final IconData icon;
  final Color color;
  final String title;
  final String message;
}

List<_OnboardingItem> _itemsFor(AppStrings s) => [
  _OnboardingItem(
    Icons.timer_outlined,
    AppColors.primary,
    s.onboarding1Title,
    s.onboarding1Body,
  ),
  _OnboardingItem(
    Icons.checklist_rounded,
    AppColors.shortBreak,
    s.onboarding2Title,
    s.onboarding2Body,
  ),
  _OnboardingItem(
    Icons.insights_rounded,
    AppColors.longBreak,
    s.onboarding3Title,
    s.onboarding3Body,
  ),
];

const int _pageCount = 3;

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(pageCount: _pageCount),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final settings = context.read<SettingsCubit>();
    final auth = context.read<AuthCubit>();
    await settings.completeOnboarding();
    await auth.checkSession();
  }

  void _next(OnboardingCubit cubit) {
    if (cubit.isLastPage) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final items = _itemsFor(s);
    final cubit = context.watch<OnboardingCubit>();
    final index = cubit.state;
    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 520,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              Row(
                children: [
                  const LanguageButton(),
                  const Spacer(),
                  TextButton(onPressed: _finish, child: Text(s.skip)),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: items.length,
                  onPageChanged: cubit.setPage,
                  itemBuilder: (context, i) => _OnboardingSlide(item: items[i]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(items.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == index ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _next(cubit),
                child: Text(cubit.isLastPage ? s.getStarted : s.next),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.item});

  final _OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    // Ukuran ilustrasi mengikuti tinggi layar agar tidak overflow di layar
    // pendek (landscape / jendela kecil); sisanya bisa di-scroll.
    return LayoutBuilder(
      builder: (context, constraints) {
        final circle = (constraints.maxHeight * 0.4).clamp(72.0, 160.0);
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: circle,
                  height: circle,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, size: circle * 0.45, color: item.color),
                ),
                SizedBox(height: circle * 0.25),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
