import 'package:flutter/widgets.dart';

import '../errors/app_exception.dart';
import '../utils/validators.dart';

part 'app_strings_en.dart';
part 'app_strings_id.dart';

/// Semua teks yang tampil di aplikasi, dalam Bahasa Indonesia dan English.
///
/// Pemakaian di widget: `final s = AppStrings.of(context);` lalu `s.login`.
/// Untuk menambah bahasa baru cukup buat turunan kelas ini dan daftarkan
/// di [supportedLocales] serta [forLanguageCode].
abstract class AppStrings {
  const AppStrings();

  static const List<Locale> supportedLocales = [Locale('id'), Locale('en')];

  static const LocalizationsDelegate<AppStrings> delegate = _AppStringsDelegate();

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings) ?? const AppStringsId();

  static AppStrings forLanguageCode(String code) =>
      code == 'en' ? const AppStringsEn() : const AppStringsId();

  static bool isSupported(String code) =>
      supportedLocales.any((locale) => locale.languageCode == code);

  String get languageCode;

  // ---------- Umum ----------
  String get appName => 'Focura';
  String get tagline;
  String get cancel;
  String get delete;
  String get retry;
  String get later;
  String get language;
  String languageName(String code) =>
      code == 'en' ? 'English' : 'Bahasa Indonesia';
  String get languageChanged;

  // ---------- Onboarding ----------
  String get skip;
  String get next;
  String get getStarted;
  String get onboarding1Title;
  String get onboarding1Body;
  String get onboarding2Title;
  String get onboarding2Body;
  String get onboarding3Title;
  String get onboarding3Body;

  // ---------- Auth ----------
  String get welcomeBack;
  String get loginSubtitle;
  String get emailHint;
  String get passwordHint;
  String get showPassword;
  String get hidePassword;
  String get login;
  String get noAccount;
  String get register;
  String fillDemoAccount(String email);
  String get signInWithGoogle;
  String get orDivider;
  String get createAccount;
  String get registerSubtitle;
  String get fullNameHint;
  String get newPasswordHint;
  String get confirmPasswordHint;

  // ---------- Navigasi ----------
  String get navTimer;
  String get navTasks;
  String get navMotivation;
  String get navProfile;

  // ---------- Timer ----------
  String get timerHeadline;
  String sessionsTodayTooltip(int count);
  String get todayFocus;
  String sessionsCompleted(int count);
  String minutes(int count);
  String get chooseMode;
  String get modeFocusShort;
  String get modeShortBreakShort;
  String get modeLongBreakShort;
  String get modeFocus;
  String get modeShortBreak;
  String get modeLongBreak;
  String get modeFocusTitle;
  String get modeShortBreakTitle;
  String get modeLongBreakTitle;
  String get modeFocusDescription;
  String get modeShortBreakDescription;
  String get modeLongBreakDescription;
  String get pause;
  String get startFocus;
  String get startBreak;
  String get resetTimer;
  String get skipSession;
  String get focusCycle;
  String get activeTaskLabel;
  String get pickTaskHint;
  String get noPendingTasks;
  String pomodoroOf(int done, int total);
  String get quoteDuringBreak;
  String get quoteMotivation;

  // ---------- Sesi selesai & notifikasi ----------
  String get focusDoneTitle;
  String get breakDoneTitle;
  String focusDoneBody(int sessions, String nextMode);
  String get breakDoneBody;
  String startMode(String mode);
  String get notifChannelName;
  String get notifChannelDescription;
  String get notifFocusTitle;
  String get notifFocusBody;
  String get notifBreakTitle;
  String get notifBreakBody;

  // ---------- Tugas ----------
  String get tasksTitle;
  String get add;
  String get filterAll;
  String get filterPending;
  String get filterCompleted;
  String completedOf(int done, int total);
  String get noTasks;
  String get noTasksInFilter;
  String get emptyTasksMessage;
  String get createFirstTask;
  String get taskAdded;
  String get taskUpdated;
  String get taskDeleted;
  String get deleteTaskTitle;
  String deleteTaskMessage(String title);
  String get edit;
  String get focusThisTask;
  String get taskOptions;
  String get focusing;
  String pomodoroCount(int done, int total);
  String get priorityLow;
  String get priorityMedium;
  String get priorityHigh;
  String get newTask;
  String get editTask;
  String get deleteTaskTooltip;
  String get titleLabel;
  String get titleHint;
  String get descriptionLabel;
  String get descriptionHint;
  String get estimateLabel;
  String estimateValue(int pomodoros, int minutes);
  String get decrease;
  String get increase;
  String get priorityLabel;
  String get addTaskButton;
  String get saveChanges;

  // ---------- Motivasi (API) ----------
  String get motivationTitle;
  String get quotesLoadFailed;
  String get offlineBanner;
  String showingQuotes(int shown, int total);
  String get allQuotesShown;
  String get loadMore;

  // ---------- Musik fokus ----------
  String get musicTitle;
  String get musicSubtitle;
  String get musicOff;
  String get trackPiano;
  String get trackAmbient;
  String get trackRain;
  String get trackOcean;
  String get trackBrownNoise;
  String get musicVolume;
  String get musicPlayDuringBreaks;
  String get musicPreview;
  String get musicPause;

  // ---------- Terjemahan kutipan ----------
  String get originalText;
  String get translating;
  String get translatedLabel;
  String get translationFailed;
  String get showTranslation;
  String get hideTranslation;
  String get switchQuoteLanguage;

  // ---------- Profil ----------
  String get profileTitle;
  String get statSessionsToday;
  String get statMinutesToday;
  String get statTotalSessions;
  String get statTasksDone;
  String get last7Days;
  List<String> get shortDayNames;
  String get timerSettings;
  String get focusDuration;
  String get shortBreakDuration;
  String get longBreakDuration;
  String minutesValue(int value);
  String get timerSaved;
  String get logout;
  String get logoutTitle;
  String get logoutMessage;
  String get footer;

  // ---------- Pesan error ----------
  String error(AppError error);

  /// Helper untuk `validator:` pada TextFormField.
  String? errorOrNull(AppError? value) => value == null ? null : error(value);
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => AppStrings.isSupported(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async =>
      AppStrings.forLanguageCode(locale.languageCode);

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
