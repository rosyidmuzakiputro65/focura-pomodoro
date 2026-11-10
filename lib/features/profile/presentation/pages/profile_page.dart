import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/backend_info.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../stats/presentation/cubit/stats_cubit.dart';
import '../../../tasks/presentation/cubit/task_cubit.dart';
import '../widgets/timer_settings_card.dart';
import '../widgets/weekly_chart.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final s = AppStrings.of(context);
    final authCubit = context.read<AuthCubit>();
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.logoutTitle),
        content: Text(s.logoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.logout),
          ),
        ],
      ),
    );
    if (yes ?? false) await authCubit.logout();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final user = context.watch<AuthCubit>().state.user;
    final stats = context.watch<StatsCubit>().state;
    final tasks = context.watch<TaskCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(s.profileTitle)),
      body: RefreshIndicator(
        onRefresh: context.read<StatsCubit>().refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          child: ResponsiveCenter(
            maxWidth: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        user?.initials ?? '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    title: Text(
                      user?.name ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(user?.email ?? '-'),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 560 ? 4 : 2;
                    final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _StatTile(
                          width: width,
                          label: s.statSessionsToday,
                          value: '${stats.todaySessions}',
                          icon: Icons.local_fire_department,
                          color: AppColors.primary,
                        ),
                        _StatTile(
                          width: width,
                          label: s.statMinutesToday,
                          value: '${stats.todayMinutes}',
                          icon: Icons.timer_outlined,
                          color: AppColors.longBreak,
                        ),
                        _StatTile(
                          width: width,
                          label: s.statTotalSessions,
                          value: '${stats.totalSessions}',
                          icon: Icons.emoji_events_outlined,
                          color: AppColors.shortBreak,
                        ),
                        _StatTile(
                          width: width,
                          label: s.statTasksDone,
                          value: '${tasks.completedCount}/${tasks.tasks.length}',
                          icon: Icons.task_alt_rounded,
                          color: Colors.amber,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _SectionTitle(s.last7Days),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
                    child: WeeklyChart(days: stats.lastSevenDays),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionTitle(s.timerSettings),
                const TimerSettingsCard(),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  key: const Key('logout_button'),
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(s.logout),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Backend: ${BackendInfo.name}'
                  '${BackendInfo.error == null ? '' : '\n${BackendInfo.error}'}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: BackendInfo.error == null
                        ? AppColors.textSecondary
                        : Colors.redAccent,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.footer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final double width;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
