# Focura — Pomodoro Timer & Task Manager

Aplikasi mobile Flutter untuk membantu mahasiswa dan pekerja mengelola waktu dengan **Teknik Pomodoro**:
sesi fokus 25 menit, istirahat pendek 5 menit, dan istirahat panjang 15 menit setiap 4 sesi.

**Kelompok 10 – Teknik Informatika, Universitas Darussalam Gontor**

| Nama | NIM |
|---|---|
| Muhammad Wildan | 452024611014 |
| Rosyid Muzakki Putro | 452024611058 |
| Alif Bima Segara | 452024611010 |

## Link

| | |
|---|---|
| 🌐 Aplikasi web (bisa dibuka dari HP/laptop mana pun) | https://rosyidmuzakiputro65.github.io/focura-pomodoro/ |
| 💻 Repositori | https://github.com/rosyidmuzakiputro65/focura-pomodoro |
| 📱 APK Android | Lihat menu **Releases** di repositori, atau build sendiri (bagian *Build rilis*) |

Akun demo: **demo@focura.app / demo123** (tombol "Isi akun demo" di halaman login), atau masuk dengan akun Google.

## Fitur

- **Splash & Onboarding** — 3 halaman, hanya muncul sekali.
- **Register, Login, Logout** dengan **Firebase Authentication**: email & password atau **Masuk dengan Google** (web: popup Google, Android: pemilih akun Google).
- **Database cloud Cloud Firestore** — tugas & riwayat sesi tersimpan per pengguna (`users/{uid}/tasks`, `users/{uid}/sessions`), bisa dibuka dari perangkat mana pun, tetap jalan offline (cache Firestore, sinkron otomatis saat online).
- **Timer Pomodoro** — mode fokus / istirahat pendek / istirahat panjang, Start, Pause, Resume, Reset, Skip, siklus 4 sesi.
- **Informasi saat sesi selesai** — dialog di dalam aplikasi + **local notification** terjadwal (tetap muncul walau aplikasi di background).
- **Musik penenang saat fokus** — 5 trek orisinal (Piano Tenang, Ambient Senja, Hujan Lembut, Ombak Pantai, Brown Noise), otomatis diputar saat sesi fokus dimulai dan berhenti saat dijeda/istirahat. Ada volume, tombol dengar, dan opsi "putar juga saat istirahat". Musik dibuat sendiri dengan `tool/generate_focus_music.py` (bebas hak cipta).
- **Task management (CRUD)** — tambah, lihat (filter Semua/Berjalan/Selesai), edit, hapus, estimasi & progres pomodoro per tugas.
- **Motivasi** — kutipan dari **DummyJSON** dengan **lazy loading** (infinite scroll per 15 data) dan cache offline, plus **terjemahan English ⇄ Indonesia** lewat API **MyMemory** (tombol **ID ⇄ EN** di setiap kartu, hasil terjemahan di-cache).
- **Profil & Statistik** — sesi & menit fokus hari ini, total, grafik 7 hari, pengaturan durasi timer, bahasa, dan info backend yang dipakai.
- **Dua bahasa aplikasi (Indonesia / English)** — teks, pesan error, validasi, dan notifikasi ikut diterjemahkan.
- **Responsif** — ponsel memakai bottom navigation, layar lebar (tablet/web) memakai navigation rail dan layout dua kolom.

## Pemetaan ke instruksi tugas

| No | Syarat | Implementasi |
|---|---|---|
| 1 | Sesuai proposal | Mode sesi, task management, informasi sesi selesai |
| 2 | Repositori GitHub publik | https://github.com/rosyidmuzakiputro65/focura-pomodoro |
| 3 | `.gitignore` standar | `build/`, `.env`, `firebase_config.json`, `google-services.json`, `key.properties`, `*.jks`, `*.apk` tidak di-commit |
| 4 | > 2 halaman, navigasi jelas, responsif | Splash, Onboarding, Login, Register, Timer, Tugas, Form Tugas, Motivasi, Profil — `lib/core/router/app_routes.dart` |
| 5 | Login & Logout | Firebase Authentication (email/password + Google) — `features/auth` |
| 6 | Business logic terpisah dari UI | Struktur `data / domain / presentation` + Cubit (`flutter_bloc`) |
| 7 | CRUD | Cloud Firestore — `features/tasks` (`TaskCubit`, `FirestoreTaskRepository`) |
| 8 | External Public API | DummyJSON Quotes + MyMemory Translation — `features/quotes/data/datasources/` |
| 9 | Library pihak ketiga | firebase_core, firebase_auth, cloud_firestore, google_sign_in, flutter_bloc, http, hive_ce, audioplayers, flutter_local_notifications, flutter_localizations, dll. |
| 10 | Local notification | `core/services/notification_service_local.dart` |
| 11 | Pagination / lazy loading / caching | `QuoteCubit.loadMore()` (limit & skip), cache Hive untuk kutipan & terjemahan, cache offline Firestore |
| 12 | Validasi sebelum disimpan | `core/utils/validators.dart` di form + repository, lalu **Firestore Security Rules** (`firestore.rules`) di server |
| 13 | Build & upload | APK release + GitHub Pages otomatis (`.github/workflows/deploy-web.yml`) |

## Arsitektur

```
lib/
├── main.dart                 # inisialisasi database, Firebase, notifikasi, dependency
├── app.dart                  # MultiBlocProvider, navigasi berdasarkan status login, bahasa
├── core/                     # tema, router, validator, database lokal, notifikasi, audio, widget umum
│   ├── config/               # konfigurasi Firebase (dart-define) & info backend
│   ├── firebase/             # pemetaan error Firebase
│   └── l10n/                 # terjemahan: app_strings.dart (+ _id, _en)
└── features/
    ├── auth/        data · domain · presentation   (Firebase Auth / lokal, login Google)
    ├── tasks/       data · domain · presentation   (CRUD Firestore / lokal)
    ├── quotes/      data · domain · presentation   (API, pagination, cache, terjemahan)
    ├── music/       data · domain · presentation   (musik penenang)
    ├── timer/       presentation                    (PomodoroCubit, halaman timer)
    ├── stats/       data · domain · presentation   (riwayat sesi fokus)
    ├── settings/    data · domain · presentation   (durasi timer, bahasa, onboarding)
    └── onboarding/ · splash/ · home/ · profile/
```

- **domain**: entity dan kontrak repository (kelas abstrak).
- **data**: implementasi repository (Firebase, Hive, HTTP).
- **presentation**: Cubit (business logic) dan widget (UI). Widget tidak mengakses database secara langsung.

Jika konfigurasi Firebase tidak tersedia, aplikasi otomatis memakai database lokal **Hive** sehingga tetap bisa dijalankan.

## Menjalankan

```bash
flutter pub get
flutter run --dart-define-from-file=firebase_config.json            # HP / emulator Android
flutter run -d chrome --dart-define-from-file=firebase_config.json  # browser
flutter test                # 43 unit & widget test
flutter analyze
```

Di VS Code tersedia task siap pakai: **Terminal → Run Task → "Focura: ..."** (cek semua, jalankan di browser, build APK, dll.).

## Konfigurasi Firebase

Project Firebase: `focura-pomodoro`.

1. **Project settings → Add app**: Web dan Android (package `com.unida.focura`).
2. Salin nilai konfigurasi ke `firebase_config.json` (contoh: `firebase_config.example.json`) — file ini **tidak di-commit**.
3. Letakkan `google-services.json` dari Firebase di `android/app/` (dibaca plugin Google Services, juga tidak di-commit).
4. **Authentication → Sign-in method**: aktifkan **Email/Password** dan **Google**.
5. **Project settings → Android app → Add fingerprint**: masukkan **SHA-1** dan **SHA-256** kunci penandatangan APK (wajib untuk login Google di Android).
6. **Authentication → Settings → Authorized domains**: tambahkan `rosyidmuzakiputro65.github.io`.
7. **Firestore Database → Create database** (production mode) → tab **Rules** → tempel isi `firestore.rules` → **Publish**.
8. GitHub Pages: repo **Settings → Secrets and variables → Actions** → secret **`FIREBASE_CONFIG_JSON`** berisi isi `firebase_config.json`.

## Build rilis

1. (Untuk Play Store) buat keystore — simpan baik-baik, **jangan di-commit**:
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   lalu buat `android/key.properties`:
   ```properties
   storePassword=PASSWORD_KEYSTORE
   keyPassword=PASSWORD_KEY
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```
   Tambahkan SHA-1/SHA-256 kunci ini ke Firebase agar login Google tetap jalan.
2. Build:
   ```bash
   flutter build apk --release --dart-define-from-file=firebase_config.json        # APK
   flutter build appbundle --release --dart-define-from-file=firebase_config.json  # Play Store (.aab)
   ```
   Hasil: `build/app/outputs/flutter-apk/app-release.apk` dan `build/app/outputs/bundle/release/app-release.aab`.

Versi web dibangun & diterbitkan otomatis ke GitHub Pages setiap push ke `main` (setelah analyze & test lulus).

## Platform yang didukung

| Platform | Status | Catatan |
|---|---|---|
| Android | ✅ | Semua fitur (notifikasi, musik, login Google) |
| Web (Chrome/Edge) | ✅ | Notifikasi diganti dialog di dalam aplikasi |
| iOS | ✅ (kode) | Perlu Mac + Xcode dan app iOS di Firebase |
| Windows / macOS / Linux | ✅ (kode) | Memakai database lokal; Windows perlu Visual Studio "Desktop development with C++" |

## Menambah / mengubah terjemahan

Semua teks ada di `lib/core/l10n/`: `app_strings.dart` (daftar kunci), `app_strings_id.dart` (Indonesia), `app_strings_en.dart` (English).
Pemakaian di widget: `final s = AppStrings.of(context);` lalu `Text(s.login)`. Lapisan data/logic tidak berisi teks:
error dikirim sebagai kode `AppError` lalu diterjemahkan di UI dengan `s.error(kode)`.

## Pemecahan masalah

- **"Masuk dengan Google butuh koneksi ke Firebase"** → aplikasi berjalan di mode lokal. Buka **Profil**: baris *Backend* menampilkan alasannya. Pastikan `google-services.json` ada di `android/app/` lalu build ulang.
- **Login Google gagal di Android** → SHA-1/SHA-256 kunci APK belum didaftarkan di Firebase.
- **"Building with plugins requires symlink support"** → aktifkan *Developer Mode* Windows: Settings → System → For developers.
- **Build APK gagal: `Could not GET https://dl.google.com/...`** → jaringan/DNS memblokir server Google. Ganti DNS ke `8.8.8.8` / `1.1.1.1` atau pakai hotspot.
- **Build APK gagal: `Could not close incremental caches ... different roots`** → proyek dan Pub cache berbeda drive; sudah diatasi dengan `kotlin.incremental=false` di `android/gradle.properties`.
- **Android toolchain: cmdline-tools missing** → Android Studio → SDK Manager → SDK Tools → *Android SDK Command-line Tools*, lalu `flutter doctor --android-licenses`.
- **Musik tidak terdengar di web** → klik dulu di halaman (aturan autoplay browser) dan pastikan volume tidak 0.
- **Terjemahan "Coba terjemahkan lagi"** → kuota harian MyMemory habis atau sedang offline; teks asli tetap tampil.
