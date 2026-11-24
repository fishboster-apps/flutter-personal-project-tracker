# TODOLIST — Phase 3: Milestone Management

> **Tujuan:** Implementasi fitur manajemen tahapan proyek (Milestone) — CRUD, checkbox penyelesaian, pengurutan manual drag-and-drop, detail tahapan, dan kalkulasi progres proyek secara real-time.  
> **Prasyarat:** Phase 2 selesai (CRUD proyek dan navigasi dasar aktif).  
> **Status:** ✅ Selesai

---

## 1. Data Layer — Model

- [x] `1.1` Buat `MilestoneModel` di `data/models/milestone_model.dart`
  - Field: `id`, `projectId`, `name`, `description`, `isCompleted`, `sortOrder`, `createdAt`, `updatedAt`
  - Method: `fromMap()`, `toMap()`, `copyWith()`

---

## 2. Data Layer — Repository

- [x] `2.1` Buat `MilestoneRepository` di `data/repositories/milestone_repository.dart`
  - [x] `insertMilestone(MilestoneModel)` → otomatis set `sort_order` tertinggi + 1
  - [x] `getMilestonesByProjectId(int projectId)` → urutkan `sort_order ASC`
  - [x] `getMilestoneById(int id)` → return `MilestoneModel?`
  - [x] `updateMilestone(MilestoneModel)` → return rows affected
  - [x] `deleteMilestone(int id)` → hapus milestone (relasi brainstorm/issue otomatis set null via SQLite FK)
  - [x] `toggleMilestoneCompletion(int id, bool isCompleted)` → update status selesai
  - [x] `reorderMilestones(int projectId, List<MilestoneModel> reorderedList)` → update `sort_order` dalam satu transaksi DB
  - [x] `getProjectProgress(int projectId)` → hitung total & milestone selesai → return persentase (0–100%)

---

## 3. Presentation — Milestone List & Reorder

File: `presentation/screens/milestones/milestone_list_screen.dart`

- [x] `3.1` Tampilkan daftar tahapan menggunakan `ReorderableListView`
- [x] `3.2` Setiap baris menampilkan: drag handle, checkbox selesai, nama tahapan, dan urutan
- [x] `3.3` Perubahan checkbox langsung mengupdate database dan merefresh tampilan/progres
- [x] `3.4` Drag-and-drop reordering: update posisi visual dan simpan perubahan urutan ke DB
- [x] `3.5` Tombol tambah tahapan (`FloatingActionButton`)
- [x] `3.6` Empty state informatif jika proyek belum memiliki tahapan
- [x] `3.7` Tap pada item mengarahkan ke `MilestoneDetailScreen`

---

## 4. Presentation — Add / Edit Milestone

File: `presentation/screens/milestones/milestone_form_dialog.dart` (atau Screen)

- [x] `4.1` Form tambah tahapan: field `name` (required), `description` (optional)
- [x] `4.2` Form edit tahapan: pre-fill data lama
- [x] `4.3` Validasi: nama tahapan tidak boleh kosong
- [x] `4.4` Simpan → insert/update database → refresh daftar tahapan
- [x] `4.5` SnackBar notifikasi sukses simpan

---

## 5. Presentation — Milestone Detail Screen

File: `presentation/screens/milestones/milestone_detail_screen.dart`

- [x] `5.1` Tampilkan detail info: nama tahapan, deskripsi, urutan, status checkbox, dan tanggal
- [x] `5.2` Seksi daftar Ide & Gagasan terkait (placeholder "0 Ide", siap terhubung di Phase 4)
- [x] `5.3` Seksi daftar Masalah & Kendala terkait (placeholder "0 Masalah", siap terhubung di Phase 4)
- [x] `5.4` Tombol edit tahapan
- [x] `5.5` Tombol hapus tahapan dengan `ConfirmDeleteDialog` (kembali ke list setelah hapus)

---

## 6. Integration — Progress Tracking

- [x] `6.1` Hubungkan menu kartu "Tahapan / Milestones" di `ProjectDetailScreen` ke `MilestoneListScreen`
- [x] `6.2` Perbarui kalkulasi progres (persentase & jumlah tahapan) di `ProjectDetailScreen`
- [x] `6.3` Perbarui kalkulasi progres (persentase & jumlah tahapan) di kartu `ProjectListScreen`

---

## 7. Verifikasi & Acceptance Criteria

- [x] `7.1` CRUD tahapan berjalan tanpa error
- [x] `7.2` Status checkbox tersimpan secara permanen di SQLite
- [x] `7.3` Urutan tahapan tersimpan konsisten setelah drag-and-drop
- [x] `7.4` Persentase progres terhitung akurat (misal: 1 dari 2 selesai = 50%, 0 tahapan = 0%)
- [x] `7.5` Menghapus tahapan tidak merusak integritas database
- [x] `7.6` `flutter analyze` 100% bersih tanpa warning
- [x] `7.7` Unit test `MilestoneRepository` & widget test lulus (28 test passed)
- [x] `7.8` Commit ke `main`: `feat: phase 3 - milestone management`

---

## Aturan Kerja Phase 3

> Fokus pada Milestone: CRUD, reordering, dan kalkulasi progres.  
> Modul Ide dan Masalah tetap berupa placeholder sampai Phase 4.  
> Catatan Activity Log untuk perubahan milestone akan diintegrasikan pada Phase 6.  
> Tetap gunakan `setState` dan navigasi bawaan Flutter.

---

*Referensi: [PRD.md](./PRD.md) — Section 3.3, 4.3, Phase 3 Development Process*
