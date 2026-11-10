import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/services/notification_service.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../quotes/presentation/cubit/quote_cubit.dart';
import '../../../quotes/presentation/pages/quotes_page.dart';
import '../../../stats/presentation/cubit/stats_cubit.dart';
import '../../../tasks/presentation/cubit/task_cubit.dart';
import '../../../tasks/presentation/pages/tasks_page.dart';
import '../../../timer/presentation/cubit/pomodoro_cubit.dart';
import '../../../timer/presentation/pages/pomodoro_page.dart';
import '../../../timer/presentation/widgets/session_complete_dialog.dart';

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

List<_Destination> _destinationsFor(AppStrings s) => [
  _Destination(s.navTimer, Icons.timer_outlined, Icons.timer_rounded),
  _Destination(s.navTasks, Icons.checklist_outlined, Icons.checklist_rounded),
  _Destination(
    s.navMotivation,
    Icons.format_quote_outlined,
    Icons.format_quote_rounded,
  ),
  _Destination(s.navProfile, Icons.person_outline_rounded, Icons.person_rounded),
];

/// Halaman utama setelah login dengan navigasi 4 tab.
/// Ponsel: NavigationBar di bawah. Tablet/Web lebar: NavigationRail di kiri.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    context.read<NotificationService>().requestPermission();
    final quotes = context.read<QuoteCubit>();
    if (quotes.state.status == QuoteStatus.initial) quotes.loadInitial();
  }

  void _select(int index) => setState(() => _index = index);

  Future<void> _onSessionFinished(BuildContext context, PomodoroState state) async {
    final finishedMode = state.lastFinishedMode;
    if (finishedMode == null) return;
    final pomodoro = context.read<PomodoroCubit>();

    if (finishedMode == PomodoroMode.focus) {
      final tasks = context.read<TaskCubit>();
      final minutes = math.max(1, (state.lastFinishedSeconds / 60).round());
      await context.read<StatsCubit>().recordFocusSession(
        minutes: minutes,
        taskTitle: tasks.state.activeTask?.title,
      );
      await tasks.recordPomodoroForActiveTask();
    }
    if (!context.mounted) return;
    await showSessionCompleteDialog(
      context,
      finishedMode: finishedMode,
      nextMode: state.mode,
      completedFocusSessions: state.completedFocusSessions,
      onStartNext: pomodoro.start,
    );
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _destinationsFor(AppStrings.of(context));
    final pages = [
      const PomodoroPage(),
      TasksPage(onStartFocus: () => _select(0)),
      const QuotesPage(),
      const ProfilePage(),
    ];

    return BlocListener<PomodoroCubit, PomodoroState>(
      listenWhen: (p, c) => c.finishedCount > p.finishedCount,
      listener: _onSessionFinished,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final body = IndexedStack(index: _index, children: pages);
          if (constraints.maxWidth >= 720) {
            return Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: _select,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final d in destinations)
                        NavigationRailDestination(
                          icon: Icon(d.icon),
                          selectedIcon: Icon(d.selectedIcon),
                          label: Text(d.label),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: body),
                ],
              ),
            );
          }
          return Scaffold(
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _select,
              destinations: [
                for (final d in destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
