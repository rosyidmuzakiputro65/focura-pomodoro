part of 'app_strings.dart';

/// English.
class AppStringsEn extends AppStrings {
  const AppStringsEn();

  @override
  String get languageCode => 'en';

  @override
  String get tagline => 'Focus first, rest later.';
  @override
  String get cancel => 'Cancel';
  @override
  String get delete => 'Delete';
  @override
  String get retry => 'Try again';
  @override
  String get later => 'Later';
  @override
  String get language => 'Language';
  @override
  String get languageChanged => 'Language changed to English';

  @override
  String get skip => 'Skip';
  @override
  String get next => 'Next';
  @override
  String get getStarted => 'Get started';
  @override
  String get onboarding1Title => 'Find your focus';
  @override
  String get onboarding1Body =>
      'Break your work into 25-minute focus sessions with the Pomodoro technique.';
  @override
  String get onboarding2Title => 'Big plans, small steps';
  @override
  String get onboarding2Body =>
      'Write down your tasks, estimate the pomodoros, then tackle them one by one.';
  @override
  String get onboarding3Title => 'Track your progress';
  @override
  String get onboarding3Body =>
      'See your daily and weekly focus sessions and get a reminder when a session ends.';

  @override
  String get welcomeBack => 'Welcome back';
  @override
  String get loginSubtitle => 'Sign in to continue your focus sessions.';
  @override
  String get emailHint => 'Email';
  @override
  String get passwordHint => 'Password';
  @override
  String get showPassword => 'Show password';
  @override
  String get hidePassword => 'Hide password';
  @override
  String get login => 'Sign in';
  @override
  String get noAccount => "Don't have an account?";
  @override
  String get register => 'Sign up';
  @override
  String fillDemoAccount(String email) => 'Use demo account ($email)';
  @override
  String get signInWithGoogle => 'Continue with Google';
  @override
  String get orDivider => 'or';
  @override
  String get createAccount => 'Create account';
  @override
  String get registerSubtitle => 'Start your focus journey with Focura.';
  @override
  String get fullNameHint => 'Full name';
  @override
  String get newPasswordHint => 'Password (min. 6, letters & numbers)';
  @override
  String get confirmPasswordHint => 'Repeat password';

  @override
  String get navTimer => 'Timer';
  @override
  String get navTasks => 'Tasks';
  @override
  String get navMotivation => 'Motivation';
  @override
  String get navProfile => 'Profile';

  @override
  String get timerHeadline => 'Make room for focus';
  @override
  String sessionsTodayTooltip(int count) =>
      '$count focus ${count == 1 ? 'session' : 'sessions'} completed today';
  @override
  String get todayFocus => "TODAY'S FOCUS";
  @override
  String sessionsCompleted(int count) =>
      '$count ${count == 1 ? 'session' : 'sessions'} completed';
  @override
  String minutes(int count) => '$count min';
  @override
  String get chooseMode => 'Choose a mode';
  @override
  String get modeFocusShort => 'Focus';
  @override
  String get modeShortBreakShort => 'Short';
  @override
  String get modeLongBreakShort => 'Long';
  @override
  String get modeFocus => 'Focus';
  @override
  String get modeShortBreak => 'Short break';
  @override
  String get modeLongBreak => 'Long break';
  @override
  String get modeFocusTitle => 'FOCUS SESSION';
  @override
  String get modeShortBreakTitle => 'SHORT BREAK';
  @override
  String get modeLongBreakTitle => 'LONG BREAK';
  @override
  String get modeFocusDescription => 'One task, one session. You’ve got this.';
  @override
  String get modeShortBreakDescription => 'Step away and let your mind reset.';
  @override
  String get modeLongBreakDescription =>
      'You earned a longer pause. Recharge well.';
  @override
  String get pause => 'Pause';
  @override
  String get startFocus => 'Start focus';
  @override
  String get startBreak => 'Start break';
  @override
  String get resetTimer => 'Reset timer';
  @override
  String get skipSession => 'Skip session';
  @override
  String get focusCycle => 'FOCUS CYCLE';
  @override
  String get activeTaskLabel => 'CURRENT FOCUS TASK';
  @override
  String get pickTaskHint => 'Tap to pick a task';
  @override
  String get noPendingTasks =>
      'No tasks in progress yet. Add one in the Tasks tab.';
  @override
  String pomodoroOf(int done, int total) => '$done of $total pomodoros';
  @override
  String get quoteDuringBreak => 'Something to reflect on';
  @override
  String get quoteMotivation => 'A little motivation';

  @override
  String get focusDoneTitle => 'Focus session complete!';
  @override
  String get breakDoneTitle => 'Break is over';
  @override
  String focusDoneBody(int sessions, String nextMode) =>
      "You've completed $sessions focus "
      "${sessions == 1 ? 'session' : 'sessions'}. "
      'Up next: ${nextMode.toLowerCase()}.';
  @override
  String get breakDoneBody => 'Recharged. Time to get back to focus.';
  @override
  String startMode(String mode) => 'Start ${mode.toLowerCase()}';
  @override
  String get notifChannelName => 'Pomodoro timer';
  @override
  String get notifChannelDescription =>
      'Alerts when a focus session or break ends';
  @override
  String get notifFocusTitle => 'Focus session complete';
  @override
  String get notifFocusBody => 'Great work! Time for a short break.';
  @override
  String get notifBreakTitle => 'Break is over';
  @override
  String get notifBreakBody => "Let's get back to your task.";

  @override
  String get tasksTitle => 'Tasks';
  @override
  String get add => 'Add';
  @override
  String get filterAll => 'All';
  @override
  String get filterPending => 'In progress';
  @override
  String get filterCompleted => 'Done';
  @override
  String completedOf(int done, int total) => '$done of $total done';
  @override
  String get noTasks => 'No tasks yet';
  @override
  String get noTasksInFilter => 'No tasks in this filter';
  @override
  String get emptyTasksMessage =>
      'Add a task, then work through it with focus sessions.';
  @override
  String get createFirstTask => 'Create your first task';
  @override
  String get taskAdded => 'Task added';
  @override
  String get taskUpdated => 'Task updated';
  @override
  String get taskDeleted => 'Task deleted';
  @override
  String get deleteTaskTitle => 'Delete task?';
  @override
  String deleteTaskMessage(String title) =>
      '"$title" will be permanently deleted.';
  @override
  String get edit => 'Edit';
  @override
  String get focusThisTask => 'Focus on this task';
  @override
  String get taskOptions => 'Task options';
  @override
  String get focusing => 'In focus';
  @override
  String pomodoroCount(int done, int total) => '$done/$total pomodoros';
  @override
  String get priorityLow => 'Low';
  @override
  String get priorityMedium => 'Medium';
  @override
  String get priorityHigh => 'High';
  @override
  String get newTask => 'New task';
  @override
  String get editTask => 'Edit task';
  @override
  String get deleteTaskTooltip => 'Delete task';
  @override
  String get titleLabel => 'Task title';
  @override
  String get titleHint => 'e.g. Write chapter 2 of the report';
  @override
  String get descriptionLabel => 'Description (optional)';
  @override
  String get descriptionHint => 'A short note about this task';
  @override
  String get estimateLabel => 'Estimated pomodoros';
  @override
  String estimateValue(int pomodoros, int minutes) =>
      '$pomodoros ${pomodoros == 1 ? 'pomodoro' : 'pomodoros'} (~$minutes min)';
  @override
  String get decrease => 'Decrease';
  @override
  String get increase => 'Increase';
  @override
  String get priorityLabel => 'Priority';
  @override
  String get addTaskButton => 'Add task';
  @override
  String get saveChanges => 'Save changes';

  @override
  String get motivationTitle => 'Motivation';
  @override
  String get quotesLoadFailed => "Couldn't load quotes";
  @override
  String get offlineBanner => 'Offline mode: showing cached data.';
  @override
  String showingQuotes(int shown, int total) =>
      'Showing $shown of $total quotes';
  @override
  String get allQuotesShown => "You've reached the end";
  @override
  String get loadMore => 'Load more';

  @override
  String get musicTitle => 'Calming music';
  @override
  String get musicSubtitle => 'Plays automatically when a focus session starts';
  @override
  String get musicOff => 'Off';
  @override
  String get trackPiano => 'Calm Piano';
  @override
  String get trackAmbient => 'Dusk Ambient';
  @override
  String get trackRain => 'Soft Rain';
  @override
  String get trackOcean => 'Ocean Waves';
  @override
  String get trackBrownNoise => 'Brown Noise';
  @override
  String get musicVolume => 'Volume';
  @override
  String get musicPlayDuringBreaks => 'Keep playing during breaks';
  @override
  String get musicPreview => 'Preview';
  @override
  String get musicPause => 'Pause music';

  @override
  String get originalText => 'Original';
  @override
  String get translating => 'Translating…';
  @override
  String get translatedLabel => 'Translated';
  @override
  String get translationFailed => 'Retry translation';
  @override
  String get showTranslation => 'Show translation';
  @override
  String get switchQuoteLanguage => 'Switch quote language (Indonesian ⇄ English)';
  @override
  String get hideTranslation => 'Show original only';

  @override
  String get profileTitle => 'Profile & Stats';
  @override
  String get statSessionsToday => 'Sessions today';
  @override
  String get statMinutesToday => 'Minutes today';
  @override
  String get statTotalSessions => 'Total sessions';
  @override
  String get statTasksDone => 'Tasks done';
  @override
  String get last7Days => 'Focus in the last 7 days';
  @override
  List<String> get shortDayNames =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  @override
  String get timerSettings => 'Settings';
  @override
  String get focusDuration => 'Focus length';
  @override
  String get shortBreakDuration => 'Short break';
  @override
  String get longBreakDuration => 'Long break';
  @override
  String minutesValue(int value) => '$value min';
  @override
  String get timerSaved => 'Timer durations saved';
  @override
  String get logout => 'Sign out';
  @override
  String get logoutTitle => 'Sign out?';
  @override
  String get logoutMessage => 'Any running timer will be stopped.';
  @override
  String get footer =>
      'Focura v1.0.0 · Group 10 · Informatics Engineering, UNIDA Gontor\n'
      'Quotes: DummyJSON · Translation: MyMemory · Music: made for Focura';

  @override
  String error(AppError error) => switch (error) {
    AppError.nameRequired => 'Name is required',
    AppError.nameTooShort =>
      'Name must be at least ${Validators.nameMin} characters',
    AppError.nameTooLong =>
      'Name must be at most ${Validators.nameMax} characters',
    AppError.emailRequired => 'Email is required',
    AppError.emailInvalid => 'Enter a valid email address',
    AppError.passwordRequired => 'Password is required',
    AppError.passwordTooShort =>
      'Password must be at least ${Validators.passwordMin} characters',
    AppError.passwordTooLong =>
      'Password must be at most ${Validators.passwordMax} characters',
    AppError.passwordWeak => 'Password must contain letters and numbers',
    AppError.confirmPasswordRequired => 'Please confirm your password',
    AppError.confirmPasswordMismatch => "Passwords don't match",
    AppError.taskTitleRequired => 'Task title is required',
    AppError.taskTitleTooShort =>
      'Title must be at least ${Validators.taskTitleMin} characters',
    AppError.taskTitleTooLong =>
      'Title must be at most ${Validators.taskTitleMax} characters',
    AppError.taskDescriptionTooLong =>
      'Description must be at most ${Validators.taskDescriptionMax} characters',
    AppError.estimateRequired => 'Estimate is required',
    AppError.estimateOutOfRange =>
      'Estimate must be between ${Validators.pomodoroMin} and '
          '${Validators.pomodoroMax} pomodoros',
    AppError.durationInvalid => 'Invalid timer duration',
    AppError.sessionDurationInvalid => 'Invalid session duration',
    AppError.pomodoroCountInvalid => 'Invalid completed pomodoro count',
    AppError.emailAlreadyRegistered =>
      'This email is already registered, please sign in',
    AppError.wrongCredentials => 'Incorrect email or password',
    AppError.notOwner => "You don't have permission to change this",
    AppError.notLoggedIn => 'Please sign in first',
    AppError.tooManyAttempts => 'Too many attempts. Please wait and try again',
    AppError.permissionDenied => 'Database access was denied',
    AppError.signInCancelled => 'Sign-in was cancelled',
    AppError.googleSignInFailed =>
      'Google sign-in failed. Try again or use email',
    AppError.googleSignInUnavailable =>
      'Google sign-in needs a Firebase connection',
    AppError.authProviderDisabled =>
      'Email/Password sign-in is not enabled in the Firebase Console',
    AppError.taskNotFound => 'Task not found',
    AppError.networkTimeout => 'The server took too long to respond',
    AppError.networkServer => 'The server has a problem, try again later',
    AppError.networkBadData => 'Unrecognized data from the server',
    AppError.networkOffline =>
      'No internet connection. Check your network.',
    AppError.translationUnavailable =>
      'Translation service is unavailable right now (daily limit reached)',
    AppError.unknown => 'Something went wrong, please try again',
  };
}
