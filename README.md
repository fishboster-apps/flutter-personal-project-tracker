# Personal Project Tracker

Aplikasi Android pribadi untuk mengelola banyak proyek, mencatat tahapan pengembangan, menyimpan ide, mendokumentasikan masalah, dan menyalin konteks proyek ke AI coding tools — semuanya secara offline.

> **Platform:** Android  
> **Framework:** Flutter  
> **Database:** SQLite (offline-first)  
> **Status:** 🚧 Aktif Dikembangkan

---

## Fitur Utama (MVP)

- 📁 **Project Management** — Kelola banyak proyek dalam satu aplikasi
- 🏁 **Milestones / Tahapan** — Catat tahapan pengembangan dengan drag & drop sorting
- 💡 **Brainstorming / Ide** — Simpan ide dan gagasan, hubungkan ke tahapan
- 🐛 **Issues / Masalah** — Dokumentasikan bug dan kendala teknis
- 🔗 **References** — Simpan tautan referensi yang relevan per proyek
- 📋 **Activity Log** — Riwayat perubahan otomatis
- 📎 **Copy Context** — Salin konteks proyek sebagai prompt terstruktur untuk AI

---

## Tech Stack

| Komponen | Teknologi |
|---|---|
| Framework | Flutter (Dart) |
| Database | SQLite via `sqflite` |
| State Management | `setState` / StatefulWidget |
| Navigasi | Navigator bawaan Flutter |
| UI | Material 3 — Dark Mode only |
| Date Format | `intl` |
| URL Launcher | `url_launcher` |

---

## Struktur Folder

```
lib/
├── main.dart                        ← Entry point
├── app.dart                         ← MaterialApp root
├── core/
│   └── theme.dart                   ← Dark theme & color tokens
├── data/
│   ├── database/
│   │   ├── database_helper.dart     ← Singleton SQLite manager
│   │   └── migrations.dart          ← Schema creation & versioning
│   ├── models/                      ← Data models per entitas
│   └── repositories/                ← Akses database per entitas
├── services/                        ← Copy context, activity log, export
└── presentation/
    ├── screens/                     ← Layar per fitur
    └── widgets/                     ← Reusable UI components
```

---

## Color Palette (Dark Theme)

| Token | Hex |
|---|---|
| Background | `#121212` |
| Surface | `#1C1C1E` |
| Surface Elevated | `#252528` |
| Primary Accent | `#8B9CF6` |
| Primary Text | `#F5F5F5` |
| Secondary Text | `#A1A1AA` |
| Border | `#343438` |
| Success | `#81C995` |
| Warning | `#E9B96E` |
| Error | `#E98282` |

---

## Development Phases

| Phase | Deskripsi | Status |
|---|---|---|
| Phase 1 | Project Foundation (setup, tema, database) | ✅ Selesai |
| Phase 2 | Project Management (CRUD proyek) | ✅ Selesai |
| Phase 3 | Milestone Management | 🔲 Belum Dimulai |
| Phase 4 | Brainstorming & Issues | 🔲 Belum Dimulai |
| Phase 5 | References | 🔲 Belum Dimulai |
| Phase 6 | Activity Log | 🔲 Belum Dimulai |
| Phase 7 | Copy Context | 🔲 Belum Dimulai |
| Phase 8 | Testing & Stabilization | 🔲 Belum Dimulai |
| Phase 9 | Future Development (Excel Export, Backup) | 🔲 Belum Dimulai |

---

## Dokumentasi

- [`docs/PRD.md`](docs/PRD.md) — Product Requirements Document
- [`docs/TODOLIST-PHASE-1.md`](docs/TODOLIST-PHASE-1.md) — Checklist Phase 1
- [`docs/TODOLIST-PHASE-2.md`](docs/TODOLIST-PHASE-2.md) — Checklist Phase 2
- [`docs/TODOLIST-PHASE-3.md`](docs/TODOLIST-PHASE-3.md) — Checklist Phase 3

---

## Cara Menjalankan

```bash
# Install dependencies
flutter pub get

# Jalankan di emulator/device
flutter run

# Jalankan unit test
flutter test

# Static analysis
flutter analyze
```

---

*Proyek ini dikembangkan untuk penggunaan pribadi sebagai solo developer tool.*
