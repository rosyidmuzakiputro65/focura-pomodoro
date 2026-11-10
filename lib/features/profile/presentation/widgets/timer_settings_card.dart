import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/language_button.dart';
import '../../../settings/domain/entities/timer_settings.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';

class TimerSettingsCard extends StatelessWidget {
  const TimerSettingsCard({super.key});

  static const _focusOptions = [15, 20, 25, 30, 45, 50, 60];
  static const _shortOptions = [3, 5, 10, 15];
  static const _longOptions = [10, 15, 20, 30];

  Future<void> _update(BuildContext context, TimerSettings next) async {
    final s = AppStrings.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<SettingsCubit>().updateTimer(next);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error == null ? s.timerSaved : s.error(error)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final settings = context.watch<SettingsCubit>().state.timer;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            const LanguageSettingTile(),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _DurationTile(
              icon: Icons.timer_outlined,
              label: s.focusDuration,
              value: settings.focusMinutes,
              options: _focusOptions,
              onChanged: (v) => _update(context, settings.copyWith(focusMinutes: v)),
            ),
            _DurationTile(
              icon: Icons.coffee_outlined,
              label: s.shortBreakDuration,
              value: settings.shortBreakMinutes,
              options: _shortOptions,
              onChanged: (v) =>
                  _update(context, settings.copyWith(shortBreakMinutes: v)),
            ),
            _DurationTile(
              icon: Icons.self_improvement_rounded,
              label: s.longBreakDuration,
              value: settings.longBreakMinutes,
              options: _longOptions,
              onChanged: (v) =>
                  _update(context, settings.copyWith(longBreakMinutes: v)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationTile extends StatelessWidget {
  const _DurationTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final int value;
  final List<int> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final items = {...options, value}.toList()..sort();
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: DropdownButton<int>(
        value: value,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(12),
        items: [
          for (final minutes in items)
            DropdownMenuItem(
              value: minutes,
              child: Text(s.minutesValue(minutes)),
            ),
        ],
        onChanged: (selected) {
          if (selected != null && selected != value) onChanged(selected);
        },
      ),
    );
  }
}
