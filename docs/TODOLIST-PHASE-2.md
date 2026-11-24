# TODOLIST — Phase 2: Project Management

> **Tujuan:** Implementasi fitur inti manajemen proyek — CRUD lengkap, search, filter status, dan navigasi ke detail proyek.  
> **Prasyarat:** Phase 1 selesai (database terbuat, tema aktif, struktur folder siap).  
> **Status:** 🔲 Belum Dimulai

---

## 1. Data Layer — Model

- [ ] `1.1` Buat `ProjectModel` di `data/models/project_model.dart`
  - Field: `id`, `name`, `description`, `status`, `createdAt`, `updatedAt`
  - Method: `fromMap()`, `toMap()`, `copyWith()`
  - Enum `ProjectStatus`: `active`, `on_hold`, `completed`, `archived`

---

## 2. Data Layer — Repository

- [ ] `2.1` Buat `ProjectRepository` di `data/repositories/project_repository.dart`
  - [ ] `insertProject(ProjectModel)` → return `int` (id baru)
  - [ ] `getAllProjects()` → return `List<ProjectModel>`
  - [ ] `getProjectById(int id)` → return `ProjectModel?`
  - [ ] `updateProject(ProjectModel)` → return `int` (rows affected)
  - [ ] `deleteProject(int id)` → return `int` (rows affected)
  - [ ] `searchProjects(String query)` → return `List<ProjectModel>` (filter by `name`)
  - [ ] `getProjectsByStatus(ProjectStatus)` → return `List<ProjectModel>`

---

## 3. Presentation — Project List Screen

File: `presentation/screens/projects/project_list_screen.dart`

- [ ] `3.1` Tampilkan daftar proyek menggunakan `ListView`
- [ ] `3.2` Setiap item menampilkan: nama proyek, deskripsi singkat, status badge, dan persentase progres tahapan (sementara tampilkan 0% jika belum ada milestone)
- [ ] `3.3` Tombol tambah proyek (`FloatingActionButton`)
- [ ] `3.4` Search bar untuk filter nama proyek (input → reload list)
- [ ] `3.5` Filter status proyek: All / Active / On Hold / Completed / Archived
- [ ] `3.6` Empty state jika belum ada proyek (teks + ikon ajakan menambah)
- [ ] `3.7` Navigasi ke `ProjectDetailScreen` saat proyek di-tap
- [ ] `3.8` Jadikan `ProjectListScreen` sebagai `home` di `App`

---

## 4. Presentation — Add / Edit Project

File: `presentation/screens/projects/project_form_screen.dart`

- [ ] `4.1` Form tambah proyek: field `name` (required), `description` (optional)
- [ ] `4.2` Form edit proyek: pre-fill data, termasuk pilihan `status`
- [ ] `4.3` Validasi: nama tidak boleh kosong
- [ ] `4.4` Simpan → insert/update ke database → kembali ke list (dengan refresh)
- [ ] `4.5` Tampilkan `SnackBar` berhasil setelah simpan
- [ ] `4.6` Navigasi menggunakan `Navigator.push` → `await` → reload list setelah kembali

---

## 5. Presentation — Project Detail Screen

File: `presentation/screens/projects/project_detail_screen.dart`

- [ ] `5.1` Tampilkan `name`, `description`, `status`, `created_at` proyek
- [ ] `5.2` Tampilkan persentase progres tahapan (hitung dari database, placeholder 0% di Phase ini)
- [ ] `5.3` Menu navigasi ke fitur lain (Tahapan, Ide, Masalah, Referensi, Riwayat) — cukup tampilkan sebagai ListTile/tombol placeholder yang belum aktif
- [ ] `5.4` Tombol edit proyek (arahkan ke `ProjectFormScreen`)
- [ ] `5.5` Tombol hapus proyek dengan dialog konfirmasi
- [ ] `5.6` Hapus → kembali ke `ProjectListScreen` dan refresh list

---

## 6. Delete Confirmation Dialog

- [ ] `6.1` Buat widget reusable `ConfirmDeleteDialog` di `presentation/widgets/`
  - Parameter: `title`, `message`, `onConfirm`
  - Tombol: "Batal" dan "Hapus" (warna `AppColors.error`)

---

## 7. Verifikasi & Acceptance Criteria

- [ ] `7.1` CRUD proyek berjalan sepenuhnya
- [ ] `7.2` Data tersimpan di SQLite dan tidak hilang setelah aplikasi ditutup
- [ ] `7.3` Search dan filter status berjalan
- [ ] `7.4` Navigasi antar halaman berjalan (list → detail → form → kembali)
- [ ] `7.5` Empty state tampil saat belum ada proyek
- [ ] `7.6` Konfirmasi hapus wajib muncul sebelum data terhapus
- [ ] `7.7` SnackBar muncul setelah aksi berhasil
- [ ] `7.8` `flutter analyze` bersih
- [ ] `7.9` `flutter test` lulus (tambahkan test untuk `ProjectRepository`)
- [ ] `7.10` Commit ke `main`: `feat: phase 2 - project management`

---

## Aturan Kerja Phase 2

> Belum ada Activity Log di phase ini — dicatat ke PRD untuk Phase 6.  
> Belum ada progress % aktual dari milestone — tampilkan 0% sebagai placeholder.  
> Gunakan `setState` untuk state management sederhana, tidak perlu Provider/Bloc.  
> Semua form & dialog menggunakan `showDialog` atau `Navigator.push`, bukan `showBottomSheet` dulu.

---

*Referensi: [PRD.md](./PRD.md) — Section 3.1, 3.2, 4.1–4.3, Phase 2 Development Process*
