# Focura — Pomodoro Timer & Task Manager

Aplikasi mobile Flutter untuk membantu mahasiswa dan pekerja mengelola waktu dengan **Teknik Pomodoro**:
sesi fokus 25 menit, istirahat pendek 5 menit, dan istirahat panjang 15 menit setiap 4 sesi.

**Kelompok 10 – Teknik Informatika, Universitas Darussalam Gontor**

| Nama | NIM |
|---|---|
| Muhammad Wildan | 452024611014 |
| Rosyid Muzakki Putro | 452024611058 |
| Alif Bima Segara | 452024611010 |

## Fitur

- **Splash & Onboarding** (3 halaman, hanya muncul sekali).
- **Register, Login, Logout** — password di-hash SHA-256 + salt, sesi tersimpan.
- **Timer Pomodoro** — mode fokus / istirahat pendek / istirahat panjang, Start, Pause, Resume, Reset, Skip, siklus 4 sesi.
- **Informasi saat sesi selesai** — dialog di dalam aplikasi + **local notification** terjadwal (tetap muncul walau aplikasi di background).
- **Task management (CRUD)** — tambah, lihat (filter Semua/Berjalan/Selesai), edit, hapus (menu atau geser), estimasi & progres pomodoro per tugas.
- **Motivasi** — kutipan dari **External Public API** `https://dummyjson.com/quotes` dengan **lazy loading** (infinite scroll per 15 data) dan **cache offline**.
- **Profil & Statistik** — sesi & menit fokus hari ini, total, grafik 7 hari, pengaturan durasi timer.
- **Musik penenang saat fokus** — 5 trek orisinal (Piano Tenang, Ambient Senja, Hujan Lembut, Ombak Pantai, Brown Noise) otomatis diputar ketika sesi fokus dimulai dan berhenti saat dijeda/istirahat. Ada pengatur volume, tombol dengar, dan opsi "putar juga saat istirahat". Musik dibuat sendiri dengan `tool/generate_focus_music.py` (bebas hak cipta).
- **Terjemahan kutipan (English ⇄ Indonesia)** — kutipan DummyJSON diterjemahkan otomatis dengan API publik MyMemory, tombol **ID ⇄ EN** di setiap kartu, hasil terjemahan disimpan di cache.
- **Dua bahasa (Indonesia / English)** — tombol bahasa di onboarding, login, register, dan Profil. Pilihan disimpan; jika belum memilih, mengikuti bahasa perangkat. Pesan error, validasi, dan notifikasi ikut diterjemahkan.
- **Responsif** — ponsel memakai bottom navigation, layar lebar (tablet/web) memakai navigation rail dan layout dua kolom.

Akun demo: **demo@focura.app / demo123** (tombol "Isi akun demo" di halaman login).

## Pemetaan ke instruksi tugas

| No | Syarat | Implementasi |
|---|---|---|
| 1 | Sesuai proposal | Mode sesi, task management, informasi sesi selesai |
| 2 | Repositori GitHub publik | Lihat bagian *Upload ke GitHub* |
| 3 | `.gitignore` standar | `build/`, `.env`, `key.properties`, `*.jks`, kredensial Firebase diabaikan |
| 4 | > 2 halaman, navigasi jelas, responsif | Splash, Onboarding, Login, Register, Timer, Tugas, Form Tugas, Motivasi, Profil — `lib/core/router/app_routes.dart` |
| 5 | Login & Logout | `features/auth` (`AuthCubit`, `LocalAuthRepository`) |
| 6 | Business logic terpisah dari UI | Struktur `data / domain / presentation` + Cubit (`flutter_bloc`) |
| 7 | CRUD | `features/tasks` (`TaskCubit`, `LocalTaskRepository`) |
| 8 | External Public API | DummyJSON Quotes + MyMemory Translation — `features/quotes/data/datasources/` |
| 9 | Library pihak ketiga | audioplayers, flutter_localizations, flutter_bloc, equatable, http, hive_ce, crypto, flutter_local_notifications, timezone |
| 10 | Local notification | `core/services/notification_service_local.dart` |
| 11 | Pagination / lazy loading / caching | `QuoteCubit.loadMore()` (limit & skip) + `HiveQuoteCache` |
| 12 | Validasi sebelum disimpan | `core/utils/validators.dart` dipakai di form **dan** di repository sebelum menulis ke database |
| 13 | Build & upload | Lihat bagian *Build rilis* |

## Arsitektur

```
lib/
├── main.dart                 # inisialisasi database, notifikasi, dependency
├── app.dart                  # MultiBlocProvider, navigasi berdasarkan status login
├── core/                     # tema, router, validator, database, notifikasi, widget umum
│   └── l10n/                 # terjemahan: app_strings.dart (+ _id, _en)
└── features/
    ├── auth/        data · domain · presentation   (login, register, logout)
    ├── tasks/       data · domain · presentation   (CRUD tugas)
    ├── quotes/      data · domain · presentation   (API + pagination + cache)
    ├── timer/       presentation                    (PomodoroCubit, halaman timer)
    ├── stats/       data · domain · presentation   (riwayat sesi fokus)
    ├── settings/    data · domain · presentation   (durasi timer, onboarding)
    ├── onboarding/ · splash/ · home/ · profile/
```

- **domain**: entity dan kontrak repository (kelas abstrak).
- **data**: implementasi repository (Hive, HTTP).
- **presentation**: Cubit (business logic) dan widget (UI). Widget tidak mengakses database secara langsung.

Database lokal memakai **Hive** sehingga berjalan di Android, iOS, dan Web (IndexedDB).

## Menjalankan

```bash
flutter pub get
flutter run                 # emulator / HP Android
flutter run -d chrome       # browser
flutter test                # 42 unit & widget test
flutter analyze
```

> Notifikasi lokal hanya aktif di Android/iOS. Di Web, informasi sesi selesai tetap tampil sebagai dialog.

## Build rilis (Google Play)

1. Buat keystore (sekali saja, simpan baik-baik, **jangan di-commit**):
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Buat file `android/key.properties`:
   ```properties
   storePassword=PASSWORD_KEYSTORE
   keyPassword=PASSWORD_KEY
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```
3. Build:
   ```bash
   flutter build appbundle --release   # untuk Play Store (.aab)
   flutter build apk --release         # untuk dibagikan langsung (.apk)
   ```
   Hasil: `build/app/outputs/bundle/release/app-release.aab` dan `build/app/outputs/flutter-apk/app-release.apk`.

Application ID: `com.unida.focura`.

## Upload ke GitHub

```bash
git init
git add .
git commit -m "Focura: pomodoro timer dengan auth, CRUD tugas, API, notifikasi"
git branch -M main
git remote add origin https://github.com/<username>/focura.git
git push -u origin main
```

Lampirkan APK rilis di menu **Releases** GitHub agar dosen bisa langsung mencoba.

## Menambah / mengubah terjemahan

Semua teks ada di `lib/core/l10n/`:

- `app_strings.dart` — daftar kunci teks (kelas abstrak).
- `app_strings_id.dart` — Bahasa Indonesia.
- `app_strings_en.dart` — English.

Pemakaian di widget: `final s = AppStrings.of(context);` lalu `Text(s.login)`.
Lapisan data/logic tidak berisi teks: error dikirim sebagai kode `AppError` lalu diterjemahkan di UI
dengan `s.error(kode)`. Jika ada kunci yang lupa diterjemahkan, `flutter analyze` langsung memberi error.

## Platform yang didukung

| Platform | Status | Catatan |
|---|---|---|
| Android | ✅ | Notifikasi, musik, semua fitur. Build: `flutter build apk --release` |
| Web (Chrome/Edge) | ✅ | Musik & terjemahan jalan; notifikasi diganti dialog di dalam aplikasi |
| iOS | ✅ (kode) | Perlu Mac + Xcode untuk build |
| Windows / macOS / Linux | ✅ (kode) | Windows perlu Visual Studio "Desktop development with C++" |

## Pemecahan masalah

- **"Building with plugins requires symlink support"** → aktifkan *Developer Mode* Windows: Settings → System → For developers.
- **Build APK gagal: `Could not GET https://dl.google.com/...` / `Connection refused`** → jaringan/DNS memblokir server Google
  (alamat `dl.google.com` diarahkan ke IP lokal). Ganti DNS Windows ke `8.8.8.8` / `1.1.1.1`, atau pakai hotspot HP, lalu build ulang.
  Task VS Code *"Focura: cek koneksi ke server Google"* menyimpan hasil diagnosisnya di `_logs/network.txt`.
- **Build APK gagal: `Could not close incremental caches ... different roots`** → terjadi karena proyek di drive D: sedangkan
  Pub cache di C:. Sudah diatasi dengan `kotlin.incremental=false` di `android/gradle.properties`.
- **Android toolchain: cmdline-tools missing** → Android Studio → SDK Manager → SDK Tools → centang *Android SDK Command-line Tools*,
  lalu jalankan `flutter doctor --android-licenses` dan jawab `y`.
- **Musik tidak terdengar di web** → klik dulu di halaman (aturan autoplay browser), pastikan volume di kartu musik tidak 0,
  dan jalankan ulang server setelah mengubah kode (mode release tidak memuat ulang otomatis).
- **Terjemahan "Coba terjemahkan lagi"** → kuota harian MyMemory habis atau sedang offline; teks asli tetap tampil.
