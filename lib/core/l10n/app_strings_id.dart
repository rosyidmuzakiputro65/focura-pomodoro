part of 'app_strings.dart';

/// Bahasa Indonesia.
class AppStringsId extends AppStrings {
  const AppStringsId();

  @override
  String get languageCode => 'id';

  @override
  String get tagline => 'Fokus dulu, istirahat kemudian.';
  @override
  String get cancel => 'Batal';
  @override
  String get delete => 'Hapus';
  @override
  String get retry => 'Coba lagi';
  @override
  String get later => 'Nanti';
  @override
  String get language => 'Bahasa';
  @override
  String get languageChanged => 'Bahasa diganti ke Bahasa Indonesia';

  @override
  String get skip => 'Lewati';
  @override
  String get next => 'Lanjut';
  @override
  String get getStarted => 'Mulai sekarang';
  @override
  String get onboarding1Title => 'Temukan fokusmu';
  @override
  String get onboarding1Body =>
      'Bagi pekerjaan menjadi sesi fokus 25 menit dengan teknik Pomodoro.';
  @override
  String get onboarding2Title => 'Rencana besar, langkah kecil';
  @override
  String get onboarding2Body =>
      'Catat tugas, perkirakan jumlah pomodoro, lalu kerjakan satu per satu.';
  @override
  String get onboarding3Title => 'Lihat perkembanganmu';
  @override
  String get onboarding3Body =>
      'Pantau sesi fokus harian dan mingguan, dapatkan pengingat saat sesi selesai.';

  @override
  String get welcomeBack => 'Selamat datang kembali';
  @override
  String get loginSubtitle => 'Masuk untuk melanjutkan sesi fokusmu.';
  @override
  String get emailHint => 'Email';
  @override
  String get passwordHint => 'Password';
  @override
  String get showPassword => 'Tampilkan password';
  @override
  String get hidePassword => 'Sembunyikan password';
  @override
  String get login => 'Masuk';
  @override
  String get noAccount => 'Belum punya akun?';
  @override
  String get register => 'Daftar';
  @override
  String fillDemoAccount(String email) => 'Isi akun demo ($email)';
  @override
  String get createAccount => 'Buat akun';
  @override
  String get registerSubtitle => 'Mulai perjalanan fokusmu bersama Focura.';
  @override
  String get fullNameHint => 'Nama lengkap';
  @override
  String get newPasswordHint => 'Password (min. 6, huruf & angka)';
  @override
  String get confirmPasswordHint => 'Ulangi password';

  @override
  String get navTimer => 'Timer';
  @override
  String get navTasks => 'Tugas';
  @override
  String get navMotivation => 'Motivasi';
  @override
  String get navProfile => 'Profil';

  @override
  String get timerHeadline => 'Beri ruang untuk fokus';
  @override
  String sessionsTodayTooltip(int count) =>
      '$count sesi fokus selesai hari ini';
  @override
  String get todayFocus => 'FOKUS HARI INI';
  @override
  String sessionsCompleted(int count) => '$count sesi selesai';
  @override
  String minutes(int count) => '$count menit';
  @override
  String get chooseMode => 'Pilih mode';
  @override
  String get modeFocusShort => 'Fokus';
  @override
  String get modeShortBreakShort => 'Pendek';
  @override
  String get modeLongBreakShort => 'Panjang';
  @override
  String get modeFocus => 'Fokus';
  @override
  String get modeShortBreak => 'Istirahat pendek';
  @override
  String get modeLongBreak => 'Istirahat panjang';
  @override
  String get modeFocusTitle => 'SESI FOKUS';
  @override
  String get modeShortBreakTitle => 'ISTIRAHAT PENDEK';
  @override
  String get modeLongBreakTitle => 'ISTIRAHAT PANJANG';
  @override
  String get modeFocusDescription => 'Satu tugas, satu sesi. Kamu pasti bisa.';
  @override
  String get modeShortBreakDescription =>
      'Menjauh sebentar dan segarkan pikiran.';
  @override
  String get modeLongBreakDescription =>
      'Kamu layak istirahat lebih lama. Isi ulang energi.';
  @override
  String get pause => 'Jeda';
  @override
  String get startFocus => 'Mulai fokus';
  @override
  String get startBreak => 'Mulai istirahat';
  @override
  String get resetTimer => 'Reset timer';
  @override
  String get skipSession => 'Lewati sesi';
  @override
  String get focusCycle => 'SIKLUS FOKUS';
  @override
  String get activeTaskLabel => 'TUGAS YANG DIFOKUSKAN';
  @override
  String get pickTaskHint => 'Ketuk untuk memilih tugas';
  @override
  String get noPendingTasks =>
      'Belum ada tugas yang berjalan. Tambahkan tugas di tab Tugas.';
  @override
  String pomodoroOf(int done, int total) => '$done dari $total pomodoro';
  @override
  String get quoteDuringBreak => 'Renungan saat istirahat';
  @override
  String get quoteMotivation => 'Penyemangat';

  @override
  String get focusDoneTitle => 'Sesi fokus selesai!';
  @override
  String get breakDoneTitle => 'Istirahat selesai';
  @override
  String focusDoneBody(int sessions, String nextMode) =>
      'Kamu sudah menyelesaikan $sessions sesi fokus. '
      'Berikutnya: ${nextMode.toLowerCase()}.';
  @override
  String get breakDoneBody => 'Energi sudah terisi. Saatnya kembali fokus.';
  @override
  String startMode(String mode) => 'Mulai ${mode.toLowerCase()}';
  @override
  String get notifChannelName => 'Timer Pomodoro';
  @override
  String get notifChannelDescription =>
      'Pemberitahuan saat sesi fokus atau istirahat selesai';
  @override
  String get notifFocusTitle => 'Sesi fokus selesai';
  @override
  String get notifFocusBody => 'Kerja bagus! Saatnya istirahat sejenak.';
  @override
  String get notifBreakTitle => 'Waktu istirahat habis';
  @override
  String get notifBreakBody => 'Ayo kembali fokus ke tugasmu.';

  @override
  String get tasksTitle => 'Tugas';
  @override
  String get add => 'Tambah';
  @override
  String get filterAll => 'Semua';
  @override
  String get filterPending => 'Berjalan';
  @override
  String get filterCompleted => 'Selesai';
  @override
  String completedOf(int done, int total) => '$done dari $total selesai';
  @override
  String get noTasks => 'Belum ada tugas';
  @override
  String get noTasksInFilter => 'Tidak ada tugas di filter ini';
  @override
  String get emptyTasksMessage =>
      'Tambahkan tugas lalu kerjakan dengan sesi fokus.';
  @override
  String get createFirstTask => 'Buat tugas pertama';
  @override
  String get taskAdded => 'Tugas ditambahkan';
  @override
  String get taskUpdated => 'Tugas diperbarui';
  @override
  String get taskDeleted => 'Tugas dihapus';
  @override
  String get deleteTaskTitle => 'Hapus tugas?';
  @override
  String deleteTaskMessage(String title) => '"$title" akan dihapus permanen.';
  @override
  String get edit => 'Edit';
  @override
  String get focusThisTask => 'Fokuskan tugas ini';
  @override
  String get taskOptions => 'Opsi tugas';
  @override
  String get focusing => 'Sedang difokuskan';
  @override
  String pomodoroCount(int done, int total) => '$done/$total pomodoro';
  @override
  String get priorityLow => 'Rendah';
  @override
  String get priorityMedium => 'Sedang';
  @override
  String get priorityHigh => 'Tinggi';
  @override
  String get newTask => 'Tugas baru';
  @override
  String get editTask => 'Edit tugas';
  @override
  String get deleteTaskTooltip => 'Hapus tugas';
  @override
  String get titleLabel => 'Judul tugas';
  @override
  String get titleHint => 'Contoh: Mengerjakan bab 2 laporan';
  @override
  String get descriptionLabel => 'Deskripsi (opsional)';
  @override
  String get descriptionHint => 'Catatan singkat tentang tugas ini';
  @override
  String get estimateLabel => 'Estimasi jumlah pomodoro';
  @override
  String estimateValue(int pomodoros, int minutes) =>
      '$pomodoros pomodoro (~$minutes menit)';
  @override
  String get decrease => 'Kurangi';
  @override
  String get increase => 'Tambah';
  @override
  String get priorityLabel => 'Prioritas';
  @override
  String get addTaskButton => 'Tambah tugas';
  @override
  String get saveChanges => 'Simpan perubahan';

  @override
  String get motivationTitle => 'Motivasi';
  @override
  String get quotesLoadFailed => 'Gagal memuat kutipan';
  @override
  String get offlineBanner => 'Mode offline: menampilkan data dari cache.';
  @override
  String showingQuotes(int shown, int total) =>
      'Menampilkan $shown dari $total kutipan';
  @override
  String get allQuotesShown => 'Semua kutipan sudah ditampilkan';
  @override
  String get loadMore => 'Muat lebih banyak';

  @override
  String get musicTitle => 'Musik penenang';
  @override
  String get musicSubtitle => 'Otomatis diputar saat sesi fokus dimulai';
  @override
  String get musicOff => 'Mati';
  @override
  String get trackPiano => 'Piano Tenang';
  @override
  String get trackAmbient => 'Ambient Senja';
  @override
  String get trackRain => 'Hujan Lembut';
  @override
  String get trackOcean => 'Ombak Pantai';
  @override
  String get trackBrownNoise => 'Brown Noise';
  @override
  String get musicVolume => 'Volume';
  @override
  String get musicPlayDuringBreaks => 'Putar juga saat istirahat';
  @override
  String get musicPreview => 'Dengarkan';
  @override
  String get musicPause => 'Jeda musik';

  @override
  String get originalText => 'Teks asli';
  @override
  String get translating => 'Menerjemahkan…';
  @override
  String get translatedLabel => 'Diterjemahkan';
  @override
  String get translationFailed => 'Coba terjemahkan lagi';
  @override
  String get showTranslation => 'Tampilkan terjemahan';
  @override
  String get switchQuoteLanguage => 'Ganti bahasa kutipan (Indonesia ⇄ English)';
  @override
  String get hideTranslation => 'Tampilkan teks asli saja';

  @override
  String get profileTitle => 'Profil & Statistik';
  @override
  String get statSessionsToday => 'Sesi hari ini';
  @override
  String get statMinutesToday => 'Menit hari ini';
  @override
  String get statTotalSessions => 'Total sesi';
  @override
  String get statTasksDone => 'Tugas selesai';
  @override
  String get last7Days => 'Fokus 7 hari terakhir';
  @override
  List<String> get shortDayNames =>
      const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  @override
  String get timerSettings => 'Pengaturan';
  @override
  String get focusDuration => 'Durasi fokus';
  @override
  String get shortBreakDuration => 'Istirahat pendek';
  @override
  String get longBreakDuration => 'Istirahat panjang';
  @override
  String minutesValue(int value) => '$value menit';
  @override
  String get timerSaved => 'Durasi timer disimpan';
  @override
  String get logout => 'Keluar';
  @override
  String get logoutTitle => 'Keluar dari akun?';
  @override
  String get logoutMessage => 'Timer yang sedang berjalan akan dihentikan.';
  @override
  String get footer =>
      'Focura v1.0.0 · Kelompok 10 · Teknik Informatika UNIDA Gontor\n'
      'Kutipan: DummyJSON · Terjemahan: MyMemory · Musik: dibuat khusus untuk Focura';

  @override
  String error(AppError error) => switch (error) {
    AppError.nameRequired => 'Nama wajib diisi',
    AppError.nameTooShort => 'Nama minimal ${Validators.nameMin} karakter',
    AppError.nameTooLong => 'Nama maksimal ${Validators.nameMax} karakter',
    AppError.emailRequired => 'Email wajib diisi',
    AppError.emailInvalid => 'Format email tidak valid',
    AppError.passwordRequired => 'Password wajib diisi',
    AppError.passwordTooShort =>
      'Password minimal ${Validators.passwordMin} karakter',
    AppError.passwordTooLong =>
      'Password maksimal ${Validators.passwordMax} karakter',
    AppError.passwordWeak => 'Password harus berisi huruf dan angka',
    AppError.confirmPasswordRequired => 'Konfirmasi password wajib diisi',
    AppError.confirmPasswordMismatch => 'Konfirmasi password tidak sama',
    AppError.taskTitleRequired => 'Judul tugas wajib diisi',
    AppError.taskTitleTooShort =>
      'Judul minimal ${Validators.taskTitleMin} karakter',
    AppError.taskTitleTooLong =>
      'Judul maksimal ${Validators.taskTitleMax} karakter',
    AppError.taskDescriptionTooLong =>
      'Deskripsi maksimal ${Validators.taskDescriptionMax} karakter',
    AppError.estimateRequired => 'Estimasi pomodoro wajib diisi',
    AppError.estimateOutOfRange =>
      'Estimasi harus antara ${Validators.pomodoroMin} sampai '
          '${Validators.pomodoroMax} pomodoro',
    AppError.durationInvalid => 'Durasi timer tidak valid',
    AppError.sessionDurationInvalid => 'Durasi sesi tidak valid',
    AppError.pomodoroCountInvalid => 'Jumlah pomodoro selesai tidak valid',
    AppError.emailAlreadyRegistered => 'Email sudah terdaftar, silakan masuk',
    AppError.wrongCredentials => 'Email atau password salah',
    AppError.notOwner => 'Kamu tidak berhak mengubah data ini',
    AppError.notLoggedIn => 'Silakan masuk terlebih dahulu',
    AppError.taskNotFound => 'Tugas tidak ditemukan',
    AppError.networkTimeout => 'Koneksi ke server terlalu lama',
    AppError.networkServer => 'Server sedang bermasalah, coba lagi nanti',
    AppError.networkBadData => 'Data dari server tidak dikenali',
    AppError.networkOffline =>
      'Tidak ada koneksi internet. Periksa jaringanmu.',
    AppError.translationUnavailable =>
      'Layanan terjemahan sedang tidak tersedia (batas harian tercapai)',
    AppError.unknown => 'Terjadi kesalahan, coba lagi',
  };
}
