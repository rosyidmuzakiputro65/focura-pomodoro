import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../stats/domain/entities/focus_session_record.dart';

/// Grafik batang sederhana menit fokus 7 hari terakhir.
class WeeklyChart extends StatelessWidget {
  const WeeklyChart({super.key, required this.days});

  final List<DailyFocus> days;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final maxMinutes = days.fold<int>(0, (max, d) => d.minutes > max ? d.minutes : max);
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final day in days)
            Expanded(
              child: Tooltip(
                message: s.minutesValue(day.minutes),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      day.minutes == 0 ? '' : '${day.minutes}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: maxMinutes == 0 ? 4 : 4 + 96 * day.minutes / maxMinutes,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: AppDateUtils.isSameDay(day.day, DateTime.now())
                            ? AppColors.primary
                            : AppColors.longBreak.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.shortDayNames[day.day.weekday - 1],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
