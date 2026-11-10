import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/circular_timer.dart';
import '../../../music/presentation/widgets/focus_music_card.dart';
import '../../../quotes/presentation/cubit/quote_cubit.dart';
import '../../../quotes/presentation/widgets/quote_card.dart';
import '../../../stats/presentation/cubit/stats_cubit.dart';
import '../../../tasks/domain/entities/focus_task.dart';
import '../../../tasks/presentation/cubit/task_cubit.dart';
import '../cubit/pomodoro_cubit.dart';
import '../widgets/timer_style.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            if (isWide) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(32),
                          child: _TimerSection(),
                        ),
                      ),
                      SizedBox(
                        width: 380,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(0, 32, 32, 32),
                          child: _SideSection(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: const SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TimerSection(),
                      SizedBox(height: 28),
                      _SideSection(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TimerSection extends StatelessWidget {
  const _TimerSection();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final state = context.watch<PomodoroCubit>().state;
    final stats = context.watch<StatsCubit>().state;
    final color = modeColor(state.mode);
    final timerSize = (MediaQuery.sizeOf(context).width - 72)
        .clamp(200.0, 300.0)
        .toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PageHeader(todaySessions: stats.todaySessions),
        const SizedBox(height: 24),
        _DailySummary(sessions: stats.todaySessions, minutes: stats.todayMinutes),
        const SizedBox(height: 28),
        Text(
          s.chooseMode,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _ModeSelector(selectedMode: state.mode, selectedColor: color),
        const SizedBox(height: 32),
        Text(
          modeTitle(s, state.mode),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: CircularTimer(
            progress: state.progress,
            timeText: state.timeText,
            timerColor: color,
            size: timerSize,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          modeDescription(s, state.mode),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        _TimerControls(isRunning: state.isRunning, color: color, mode: state.mode),
        const SizedBox(height: 28),
        _CycleProgress(sessions: state.sessionsInCurrentCycle),
      ],
    );
  }
}

class _SideSection extends StatelessWidget {
  const _SideSection();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final pomodoro = context.watch<PomodoroCubit>().state;
    final quote = context.watch<QuoteCubit>().state.quoteFor(pomodoro.finishedCount);
    final isBreak = pomodoro.mode != PomodoroMode.focus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _ActiveTaskCard(),
        const SizedBox(height: 16),
        const FocusMusicCard(),
        if (quote != null) ...[
          const SizedBox(height: 16),
          Text(
            isBreak ? s.quoteDuringBreak : s.quoteMotivation,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          QuoteCard(quote: quote, accent: modeColor(pomodoro.mode)),
        ],
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.todaySessions});

  final int todaySessions;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.timer_outlined, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.appName.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                s.timerHeadline,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Tooltip(
          message: s.sessionsTodayTooltip(todaySessions),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  size: 17,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  '$todaySessions',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DailySummary extends StatelessWidget {
  const _DailySummary({required this.sessions, required this.minutes});

  final int sessions;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.longBreak.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.track_changes_rounded,
                color: AppColors.longBreak,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.todayFocus,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.sessionsCompleted(sessions),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              s.minutes(minutes),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.selectedMode, required this.selectedColor});

  final PomodoroMode selectedMode;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<PomodoroMode>(
        showSelectedIcon: false,
        segments: [
          for (final mode in PomodoroMode.values)
            ButtonSegment(value: mode, label: Text(modeShortLabel(s, mode))),
        ],
        selected: {selectedMode},
        onSelectionChanged: (selection) {
          context.read<PomodoroCubit>().selectMode(selection.first);
        },
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 8, vertical: 13),
          ),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? selectedColor
                : AppColors.textSecondary;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? selectedColor.withValues(alpha: 0.12)
                : AppColors.cardBg;
          }),
          side: const WidgetStatePropertyAll(BorderSide(color: AppColors.border)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}

class _TimerControls extends StatelessWidget {
  const _TimerControls({
    required this.isRunning,
    required this.color,
    required this.mode,
  });

  final bool isRunning;
  final Color color;
  final PomodoroMode mode;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cubit = context.read<PomodoroCubit>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: SizedBox(
            width: 208,
            child: ElevatedButton.icon(
              key: const Key('timer_toggle'),
              onPressed: cubit.toggle,
              icon: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
              label: Text(
                isRunning
                    ? s.pause
                    : mode == PomodoroMode.focus
                    ? s.startFocus
                    : s.startBreak,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: AppColors.background,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          tooltip: s.resetTimer,
          onPressed: cubit.reset,
          icon: const Icon(Icons.refresh_rounded),
          style: IconButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            backgroundColor: AppColors.cardBg,
            minimumSize: const Size(50, 50),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: s.skipSession,
          onPressed: cubit.skip,
          icon: const Icon(Icons.skip_next_rounded),
          style: IconButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            minimumSize: const Size(46, 50),
          ),
        ),
      ],
    );
  }
}

class _CycleProgress extends StatelessWidget {
  const _CycleProgress({required this.sessions});

  final int sessions;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              s.focusCycle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$sessions / 4',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: index == 3 ? 0 : 7),
                decoration: BoxDecoration(
                  color: index < sessions ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ActiveTaskCard extends StatelessWidget {
  const _ActiveTaskCard();

  Future<void> _pickTask(BuildContext context, List<FocusTask> tasks) async {
    final s = AppStrings.of(context);
    final cubit = context.read<TaskCubit>();
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.cardBg,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: tasks.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(s.noPendingTasks, textAlign: TextAlign.center),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final task in tasks)
                    ListTile(
                      leading: const Icon(Icons.radio_button_unchecked_rounded),
                      title: Text(task.title),
                      subtitle: Text(
                        s.pomodoroCount(
                          task.completedPomodoros,
                          task.estimatedPomodoros,
                        ),
                      ),
                      onTap: () => Navigator.pop(context, task.id),
                    ),
                ],
              ),
      ),
    );
    if (selected != null) cubit.setActiveTask(selected);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final taskState = context.watch<TaskCubit>().state;
    final task = taskState.activeTask;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _pickTask(context, taskState.pendingTasks),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.flag_circle_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.activeTaskLabel,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task?.title ?? s.pickTaskHint,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (task != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: task.progress,
                          minHeight: 4,
                          backgroundColor: AppColors.border,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.pomodoroOf(
                          task.completedPomodoros,
                          task.estimatedPomodoros,
                        ),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.unfold_more_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
