# TODOLIST — Phase 1: Project Foundation

> **Tujuan:** Setup pondasi teknikal agar seluruh fase berikutnya dapat dibangun di atas struktur yang konsisten.  
> **Status:** ⏳ Sedang Berjalan (Poin 1–6 Selesai)

---

## 1. Dependencies

- [x] `1.1` Tambahkan `sqflite` → akses SQLite
- [x] `1.2` Tambahkan `path` → path database SQLite
- [x] `1.3` Tambahkan `intl` → format tanggal/waktu
- [x] `1.4` Tambahkan `url_launcher` → buka URL di browser eksternal
- [x] `1.5` Jalankan `flutter pub get` dan verifikasi tidak ada konflik

---

## 2. Folder Structure

Buat struktur folder `lib/` berikut:

```
lib/
├── main.dart
├── app.dart                    ← MaterialApp root
├── core/
│   └── theme.dart              ← Dark theme & color palette
├── data/
│   ├── database/
│   │   ├── database_helper.dart
│   │   └── migrations.dart
│   ├── models/                 ← (kosong, diisi Phase 2+)
│   └── repositories/           ← (kosong, diisi Phase 2+)
├── services/                   ← (kosong, diisi Phase berikutnya)
└── presentation/
    ├── screens/
    │   └── home_screen.dart    ← Placeholder screen awal
    └── widgets/                ← Reusable widgets
```

- [x] `2.1` Buat seluruh folder sesuai struktur di atas
- [x] `2.2` Buat file placeholder di setiap folder (`.gitkeep` atau file Dart kosong berkomentator)

---

## 3. Dark Theme Setup

Referensi warna dari PRD:

| Token             | Hex       |
|-------------------|-----------|
| Background        | `#121212` |
| Surface           | `#1C1C1E` |
| Surface Elevated  | `#252528` |
| Primary Accent    | `#8B9CF6` |
| Primary Text      | `#F5F5F5` |
| Secondary Text    | `#A1A1AA` |
| Border            | `#343438` |
| Success           | `#81C995` |
| Warning           | `#E9B96E` |
| Error             | `#E98282` |

- [x] `3.1` Implementasi `AppTheme` di `core/theme.dart` menggunakan Material 3
- [x] `3.2` Set `themeMode: ThemeMode.dark` — tidak ada light mode
- [x] `3.3` Definisikan `ColorScheme` sesuai palet PRD
- [x] `3.4` Verifikasi tema berjalan konsisten saat hot reload

---

## 4. App Entry Point & Navigation

- [x] `4.1` Refactor `main.dart` → hanya panggil `runApp(const App())`
- [x] `4.2` Buat `app.dart` → `MaterialApp` dengan `theme`, `darkTheme`, dan `home: HomeScreen()`
- [x] `4.3` Buat `HomeScreen` sebagai placeholder (AppBar + body kosong bertuliskan nama app)
- [x] `4.4` Verifikasi navigasi dasar berjalan (navigasi push/pop kosong antar screen tes)

---

## 5. SQLite — Database Helper

- [x] `5.1` Buat `DatabaseHelper` sebagai **singleton** di `data/database/database_helper.dart`
- [x] `5.2` Definisikan nama database: `project_tracker.db`
- [x] `5.3` Set `PRAGMA foreign_keys = ON` pada setiap koneksi
- [x] `5.4` Implementasi method `_onCreate` → jalankan migration pertama

---

## 6. SQLite — Migrations

Buat semua tabel sesuai skema PRD di `data/database/migrations.dart`.

- [x] `6.1` Tabel `projects`
- [x] `6.2` Tabel `milestones`
- [x] `6.3` Tabel `brainstorms`
- [x] `6.4` Tabel `issues`
- [x] `6.5` Tabel `references`
- [x] `6.6` Tabel `activity_logs`
- [x] `6.7` Set `PRAGMA user_version = 1` sebagai versi migrasi awal
- [x] `6.8` Siapkan pola `_onUpgrade` untuk migrasi versi berikutnya

---

## 7. Verifikasi & Acceptance Criteria

- [ ] `7.1` Aplikasi dapat dijalankan tanpa error di emulator/device Android
- [x] `7.2` Database `project_tracker.db` berhasil dibuat di direktori privat app (diverifikasi via automated test)
- [x] `7.3` Semua 6 tabel terbuat dan dapat di-inspect (diverifikasi via `test/database_test.dart`)
- [x] `7.4` Foreign key aktif & cascade/set null rules teruji (diverifikasi via `test/database_test.dart`)
- [ ] `7.5` Dark mode berjalan konsisten di seluruh layar
- [x] `7.6` Tidak ada linting warning (`flutter analyze` bersih)
- [ ] `7.7` Commit ke `main` dengan message: `feat: phase 1 - project foundation`

---

## Aturan Kerja Phase 1

> Jangan implementasi logika bisnis, UI form, atau CRUD di phase ini.  
> Fokus pada fondasi: **struktur folder**, **tema**, **database terbuat**, dan **aplikasi bisa jalan**.

---

*Referensi: [PRD.md](./PRD.md) — Section 5 (Architecture), 6 (Database Schema), 7 (Tech Stack), 8 (Design Guidelines), Phase 1 Development Process*
