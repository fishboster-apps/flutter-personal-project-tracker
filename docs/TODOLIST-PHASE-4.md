# TODOLIST — Phase 4: Brainstorming & Issues

> **Tujuan:** Implementasi modul pencatatan ide (Brainstorming) dan kendala teknis (Issues) — CRUD lengkap, checkbox selesai, relasi opsional ke tahapan, filter data, dan integrasi tampilan pada detail tahapan dan detail proyek.  
> **Prasyarat:** Phase 3 selesai (Milestone management dan progress tracking aktif).  
> **Status:** 🔲 Belum Dimulai

---

## 1. Data Layer — Models

- [ ] `1.1` Buat `BrainstormModel` di `data/models/brainstorm_model.dart`
  - Field: `id`, `projectId`, `milestoneId` (nullable), `title`, `description`, `isCompleted`, `createdAt`, `updatedAt`
  - Method: `fromMap()`, `toMap()`, `copyWith()`
- [ ] `1.2` Buat `IssueModel` di `data/models/issue_model.dart`
  - Field: `id`, `projectId`, `milestoneId` (nullable), `title`, `description`, `isCompleted`, `createdAt`, `updatedAt`
  - Method: `fromMap()`, `toMap()`, `copyWith()`

---

## 2. Data Layer — Repositories

- [ ] `2.1` Buat `BrainstormRepository` di `data/repositories/brainstorm_repository.dart`
  - [ ] `insertBrainstorm(BrainstormModel)` → return id
  - [ ] `getBrainstormsByProjectId(int projectId, {int? milestoneId, bool unassignedOnly = false})` → return `List<BrainstormModel>`
  - [ ] `getBrainstormById(int id)` → return `BrainstormModel?`
  - [ ] `updateBrainstorm(BrainstormModel)` → return rows affected
  - [ ] `deleteBrainstorm(int id)` → hapus ide
  - [ ] `toggleBrainstormCompletion(int id, bool isCompleted)` → update status selesai
  - [ ] `getBrainstormCountByProject(int projectId)` → hitung total & belum selesai
- [ ] `2.2` Buat `IssueRepository` di `data/repositories/issue_repository.dart`
  - [ ] `insertIssue(IssueModel)` → return id
  - [ ] `getIssuesByProjectId(int projectId, {int? milestoneId, bool unassignedOnly = false})` → return `List<IssueModel>`
  - [ ] `getIssueById(int id)` → return `IssueModel?`
  - [ ] `updateIssue(IssueModel)` → return rows affected
  - [ ] `deleteIssue(int id)` → hapus masalah
  - [ ] `toggleIssueCompletion(int id, bool isCompleted)` → update status selesai
  - [ ] `getIssueCountByProject(int projectId)` → hitung total & belum selesai

---

## 3. Presentation — Brainstorming (Ide & Gagasan)

Folder: `presentation/screens/brainstorms/`

- [ ] `3.1` Buat `BrainstormListScreen`:
  - Tab/Filter: Semua Ide, Berdasarkan Tahapan, atau Tanpa Tahapan
  - Checkbox selesai langsung di item list
  - Empty state ramah pengguna
  - Tombol FAB tambah ide
- [ ] `3.2` Buat `BrainstormFormDialog`:
  - Input `title` (required), `description` (optional)
  - Dropdown pilih tahapan (opsional: "Tanpa Tahapan" / list milestone proyek)
  - Validasi input & feedback SnackBar
- [ ] `3.3` Buat `BrainstormDetailScreen`:
  - Detail info ide, status, nama tahapan jika terhubung
  - Checkbox selesai
  - Tombol edit & hapus dengan `ConfirmDeleteDialog`

---

## 4. Presentation — Issues (Masalah & Kendala)

Folder: `presentation/screens/issues/`

- [ ] `4.1` Buat `IssueListScreen`:
  - Tab/Filter: Semua Masalah, Berdasarkan Tahapan, atau Tanpa Tahapan
  - Checkbox selesai langsung di item list
  - Empty state informatif
  - Tombol FAB tambah masalah
- [ ] `4.2` Buat `IssueFormDialog`:
  - Input `title` (required), `description` (optional)
  - Dropdown pilih tahapan (opsional: "Tanpa Tahapan" / list milestone proyek)
  - Validasi input & feedback SnackBar
- [ ] `4.3` Buat `IssueDetailScreen`:
  - Detail info masalah, status, nama tahapan jika terhubung
  - Checkbox selesai
  - Tombol edit & hapus dengan `ConfirmDeleteDialog`

---

## 5. Integration — Detail Screens

- [ ] `5.1` Integrasi `MilestoneDetailScreen`:
  - Tampilkan daftar nyata ide yang terhubung ke tahapan tersebut
  - Tampilkan daftar nyata masalah yang terhubung ke tahapan tersebut
  - Tombol cepat tambah ide/masalah langsung terhubung ke tahapan ini
- [ ] `5.2` Integrasi `ProjectDetailScreen`:
  - Hubungkan kartu navigasi "Ide & Gagasan" ke `BrainstormListScreen`
  - Hubungkan kartu navigasi "Masalah & Kendala" ke `IssueListScreen`
  - Tampilkan jumlah item aktif di subtitle masing-masing kartu

---

## 6. Verifikasi & Acceptance Criteria

- [ ] `6.1` CRUD ide dan masalah berjalan tanpa error
- [ ] `6.2` Relasi ke tahapan bersifat opsional (dapat dibuat dengan atau tanpa tahapan)
- [ ] `6.3` Menghapus tahapan otomatis mengubah `milestone_id` ide/masalah menjadi NULL (data tidak hilang)
- [ ] `6.4` Status checkbox tersimpan permanen di SQLite
- [ ] `6.5` `flutter analyze` 100% bersih tanpa issue
- [ ] `6.6` Unit test repositories & widget test presentation lulus
- [ ] `6.7` Commit ke `main`: `feat: phase 4 - brainstorming and issues`

---

## Aturan Kerja Phase 4

> Fokus pada Ide & Masalah: CRUD, relasi tahapan opsional, dan integrasi tampilan.  
> Modul Referensi dan Activity Log tetap disiapkan untuk fase berikutnya (Phase 5 & 6).  
> Checkbox menggunakan update instan ke SQLite.  
> Tetap pertahankan tema Dark dan clean architecture sederhana.

---

*Referensi: [PRD.md](./PRD.md) — Section 3.4, 3.5, 4.4, 4.5, Phase 4 Development Process*
