# TODOLIST — Phase 2: Project Management

> **Tujuan:** Implementasi fitur inti manajemen proyek — CRUD lengkap, search, filter status, dan navigasi ke detail proyek.  
> **Prasyarat:** Phase 1 selesai (database terbuat, tema aktif, struktur folder siap).  
> **Status:** ✅ Selesai

---

## 1. Data Layer — Model

- [x] `1.1` Buat `ProjectModel` di `data/models/project_model.dart`
  - Field: `id`, `name`, `description`, `status`, `createdAt`, `updatedAt`
  - Method: `fromMap()`, `toMap()`, `copyWith()`
  - Enum `ProjectStatus`: `active`, `on_hold`, `completed`, `archived`

---

## 2. Data Layer — Repository

- [x] `2.1` Buat `ProjectRepository` di `data/repositories/project_repository.dart`
  - [x] `insertProject(ProjectModel)` → return `int` (id baru)
  - [x] `getAllProjects()` → return `List<ProjectModel>`
  - [x] `getProjectById(int id)` → return `ProjectModel?`
  - [x] `updateProject(ProjectModel)` → return `int` (rows affected)
  - [x] `deleteProject(int id)` → return `int` (rows affected)
  - [x] `searchProjects(String query)` → return `List<ProjectModel>` (filter by `name`)
  - [x] `getProjectsByStatus(ProjectStatus)` → return `List<ProjectModel>`

---

## 3. Presentation — Project List Screen

File: `presentation/screens/projects/project_list_screen.dart`

- [x] `3.1` Tampilkan daftar proyek menggunakan `ListView`
- [x] `3.2` Setiap item menampilkan: nama proyek, deskripsi singkat, status badge, dan persentase progres tahapan (sementara tampilkan 0% jika belum ada milestone)
- [x] `3.3` Tombol tambah proyek (`FloatingActionButton`)
- [x] `3.4` Search bar untuk filter nama proyek (input → reload list)
- [x] `3.5` Filter status proyek: All / Active / On Hold / Completed / Archived
- [x] `3.6` Empty state jika belum ada proyek (teks + ikon ajakan menambah)
- [x] `3.7` Navigasi ke `ProjectDetailScreen` saat proyek di-tap
- [x] `3.8` Jadikan `ProjectListScreen` sebagai `home` di `App`

---

## 4. Presentation — Add / Edit Project

File: `presentation/screens/projects/project_form_screen.dart`

- [x] `4.1` Form tambah proyek: field `name` (required), `description` (optional)
- [x] `4.2` Form edit proyek: pre-fill data, termasuk pilihan `status`
- [x] `4.3` Validasi: nama tidak boleh kosong
- [x] `4.4` Simpan → insert/update ke database → kembali ke list (dengan refresh)
- [x] `4.5` Tampilkan `SnackBar` berhasil setelah simpan
- [x] `4.6` Navigasi menggunakan `Navigator.push` → `await` → reload list setelah kembali

---

## 5. Presentation — Project Detail Screen

File: `presentation/screens/projects/project_detail_screen.dart`

- [x] `5.1` Tampilkan `name`, `description`, `status`, `created_at` proyek
- [x] `5.2` Tampilkan persentase progres tahapan (hitung dari database, placeholder 0% di Phase ini)
- [x] `5.3` Menu navigasi ke fitur lain (Tahapan, Ide, Masalah, Referensi, Riwayat) — cukup tampilkan sebagai ListTile/tombol placeholder yang belum aktif
- [x] `5.4` Tombol edit proyek (arahkan ke `ProjectFormScreen`)
- [x] `5.5` Tombol hapus proyek dengan dialog konfirmasi
- [x] `5.6` Hapus → kembali ke `ProjectListScreen` dan refresh list

---

## 6. Delete Confirmation Dialog

- [x] `6.1` Buat widget reusable `ConfirmDeleteDialog` di `presentation/widgets/`
  - Parameter: `title`, `message`, `onConfirm`
  - Tombol: "Batal" dan "Hapus" (warna `AppColors.error`)

---

## 7. Verifikasi & Acceptance Criteria

- [x] `7.1` CRUD proyek berjalan sepenuhnya
- [x] `7.2` Data tersimpan di SQLite dan tidak hilang setelah aplikasi ditutup
- [x] `7.3` Search dan filter status berjalan
- [x] `7.4` Navigasi antar halaman berjalan (list → detail → form → kembali)
- [x] `7.5` Empty state tampil saat belum ada proyek
- [x] `7.6` Konfirmasi hapus wajib muncul sebelum data terhapus
- [x] `7.7` SnackBar muncul setelah aksi berhasil
- [x] `7.8` `flutter analyze` bersih (0 issues)
- [x] `7.9` `flutter test` lulus (16 tests passed)
- [x] `7.10` Commit ke `main`: `feat: phase 2 - project management`

---

## Aturan Kerja Phase 2

> Belum ada Activity Log di phase ini — dicatat ke PRD untuk Phase 6.  
> Belum ada progress % aktual dari milestone — tampilkan 0% sebagai placeholder.  
> Gunakan `setState` untuk state management sederhana, tidak perlu Provider/Bloc.  
> Semua form & dialog menggunakan `showDialog` atau `Navigator.push`, bukan `showBottomSheet` dulu.

---

*Referensi: [PRD.md](./PRD.md) — Section 3.1, 3.2, 4.1–4.3, Phase 2 Development Process*
