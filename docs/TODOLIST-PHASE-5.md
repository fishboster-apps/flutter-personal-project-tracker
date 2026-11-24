# TODOLIST — Phase 5: References

> **Tujuan:** Implementasi modul referensi dan tautan eksternal (References) — CRUD lengkap, validasi URL, membuka tautan via browser/aplikasi eksternal (`url_launcher`), relasi fleksibel (berdiri sendiri di proyek, terhubung ke ide, atau terhubung ke masalah), serta integrasi tampilan pada detail proyek, detail ide, dan detail masalah.  
> **Prasyarat:** Phase 4 selesai (Modul Brainstorming & Issues aktif).  
> **Status:** 🔲 Belum Dimulai

---

## 1. Data Layer — Models

- [ ] `1.1` Buat `ReferenceModel` di `data/models/reference_model.dart`
  - Field:
    - `id` (int?)
    - `projectId` (int)
    - `brainstormId` (int? nullable)
    - `issueId` (int? nullable)
    - `title` (String)
    - `url` (String)
    - `notes` (String? nullable)
    - `createdAt` (DateTime)
    - `updatedAt` (DateTime)
  - Aturan: `(brainstormId == null) || (issueId == null)` (tidak boleh terhubung ke keduanya sekaligus).
  - Method: `fromMap()`, `toMap()`, `copyWith()`

---

## 2. Data Layer — Repositories

- [ ] `2.1` Buat `ReferenceRepository` di `data/repositories/reference_repository.dart`
  - [ ] `insertReference(ReferenceModel)` → return id
  - [ ] `getReferencesByProjectId(int projectId, {int? brainstormId, int? issueId, bool standaloneOnly = false})` → return `List<ReferenceModel>`
  - [ ] `getReferenceById(int id)` → return `ReferenceModel?`
  - [ ] `updateReference(ReferenceModel)` → return rows affected
  - [ ] `deleteReference(int id)` → hapus referensi
  - [ ] `getReferenceCountByProject(int projectId)` → hitung total referensi per proyek

---

## 3. Services — URL Launcher

- [ ] `3.1` Buat helper `UrlLauncherService` di `services/url_launcher_service.dart` (atau utility method):
  - Validasi format URL (menambahkan skema `https://` otomatis jika pengguna hanya mengetik `github.com/...`)
  - Buka URL eksternal dengan mode `LaunchMode.externalApplication`
  - Error handling jika URL gagal dibuka (feedback SnackBar)

---

## 4. Presentation — References (Referensi & Tautan)

Folder: `presentation/screens/references/`

- [ ] `4.1` Buat `ReferenceListScreen`:
  - Tab/Chip Filter: Semua Tautan, Proyek Saja (Standalone), Terhubung ke Ide, Terhubung ke Masalah
  - List kartu referensi dengan preview judul, URL, catatan, badge target relasi, dan tombol aksi cepat (buka link, copy link)
  - Empty state informatif
  - Tombol FAB tambah referensi
- [ ] `4.2` Buat `ReferenceFormDialog`:
  - Input `title` (required), `url` (required, dengan validasi format), `notes` (optional)
  - Selector/Dropdown relasi:
    - "Referensi Proyek Umum" (standalone, `brainstormId = null`, `issueId = null`)
    - Pilihan Ide dari proyek (`brainstormId`)
    - Pilihan Masalah dari proyek (`issueId`)
  - Memastikan constraint mutual exclusion (tidak bisa memilih ide & masalah sekaligus)
  - Validasi input & feedback SnackBar
- [ ] `4.3` Buat `ReferenceDetailScreen` (atau bottom sheet detail):
  - Tampilkan judul lengkap, URL, catatan, waktu dibuat/diperbarui, dan target relasi
  - Tombol "Buka di Browser" (`url_launcher`)
  - Tombol "Salin Tautan" ke clipboard
  - Tombol edit & hapus dengan `ConfirmDeleteDialog`

---

## 5. Integration — Detail Screens

- [ ] `5.1` Integrasi `BrainstormDetailScreen`:
  - Tampilkan daftar referensi yang terhubung ke ide tersebut
  - Tombol cepat tambah referensi langsung terhubung ke ide ini
- [ ] `5.2` Integrasi `IssueDetailScreen`:
  - Tampilkan daftar referensi yang terhubung ke masalah tersebut
  - Tombol cepat tambah referensi langsung terhubung ke masalah ini
- [ ] `5.3` Integrasi `ProjectDetailScreen`:
  - Hubungkan kartu navigasi "Referensi & Tautan" ke `ReferenceListScreen`
  - Tampilkan jumlah referensi aktif di subtitle kartu navigasi

---

## 6. Verifikasi & Acceptance Criteria

- [ ] `6.1` CRUD referensi berjalan lancar dan tersimpan di SQLite
- [ ] `6.2` Relasi fleksibel teruji (standalone, terhubung ke ide, atau terhubung ke masalah)
- [ ] `6.3` Menghapus ide atau masalah otomatis mengubah `brainstorm_id`/`issue_id` referensi menjadi NULL (`ON DELETE SET NULL`), data referensi tidak hilang
- [ ] `6.4` URL dapat dibuka melalui browser/aplikasi eksternal
- [ ] `6.5` `flutter analyze` 100% bersih tanpa issue/warning
- [ ] `6.6` Unit test repository SQLite & widget test presentation lulus
- [ ] `6.7` Commit ke `main`: `feat: phase 5 - references`

---

## Aturan Kerja Phase 5

> Fokus pada Referensi: CRUD, validasi URL, buka tautan via `url_launcher`, relasi eksklusif, dan integrasi detail screen.  
> Pertahankan tema Dark konsisten dan struktur kode clean architecture sederhana.  
> Persiapkan data referensi agar siap dipakai modul Copy Context pada Phase 7.

---

*Referensi: [PRD.md](./PRD.md) — Section 3.7, 4.6, 9 (Phase 5)*
