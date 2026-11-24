# PRD.md
# Personal Project Tracker

**Product Type:** Android Mobile Application  
**Platform:** Android  
**Framework:** Flutter  
**Database:** Local SQLite  
**Architecture:** Offline-First  
**Version:** 1.0.0 (Initial PRD)  
**Development Approach:** MVP / Solo Developer / AI-Assisted Development

---

# 1. Overview

## 1.1 Product Background

Personal Project Tracker merupakan aplikasi Android pribadi untuk membantu developer mengelola banyak proyek, mencatat tahapan pengembangan, menyimpan ide, mencatat masalah, mendokumentasikan aktivitas, dan mengelola referensi.

Aplikasi ini dirancang khusus untuk membantu solo developer yang sering berpindah antarproyek dan mengalami kesulitan mengingat progres maupun rencana pengembangan sebelumnya.

Selain sebagai project tracker, aplikasi ini memiliki fitur utama berupa **Copy Context**, yaitu kemampuan mengubah informasi proyek menjadi teks terstruktur yang siap disalin ke prompt AI seperti ChatGPT, Gemini, Claude, maupun AI coding tools lainnya.

## 1.2 Product Goals

1. Mengelola banyak proyek dalam satu aplikasi.
2. Memudahkan pencatatan tahapan pengembangan.
3. Menampung ide tanpa harus langsung menjadikannya pekerjaan.
4. Mendokumentasikan masalah dan kendala proyek.
5. Mencatat riwayat perubahan secara otomatis.
6. Mengelola referensi berupa tautan.
7. Memudahkan pengguna menyalin konteks proyek untuk kebutuhan AI brainstorming dan vibe coding.
8. Menyimpan seluruh data secara lokal tanpa membutuhkan internet atau server.

## 1.3 Product Principles

- Simple: antarmuka sederhana dan mudah dipahami.
- Efficient: minim langkah untuk mencatat informasi.
- Offline-First: seluruh fungsi utama berjalan tanpa internet.
- Lightweight: minim dependency dan plugin tambahan.
- AI-Friendly: data mudah disalin menjadi prompt.
- Maintainable: struktur kode sederhana dan mudah dikembangkan.

## 1.4 Target Users

Solo developer, programmer, freelancer, dan individu yang mengelola beberapa proyek secara bersamaan.

---

# 2. Requirements

## 2.1 Functional Requirements

| ID | Requirement | Priority |
|---|---|---|
| FR-01 | Pengguna dapat membuat proyek | Must |
| FR-02 | Pengguna dapat mengubah dan menghapus proyek | Must |
| FR-03 | Setiap proyek memiliki nama dan deskripsi | Must |
| FR-04 | Pengguna dapat membuat banyak tahapan | Must |
| FR-05 | Tahapan dapat diurutkan menggunakan drag and drop | Must |
| FR-06 | Tahapan memiliki checkbox selesai | Must |
| FR-07 | Pengguna dapat membuat ide dan gagasan | Must |
| FR-08 | Ide dapat terhubung ke maksimal satu tahapan | Must |
| FR-09 | Ide memiliki checkbox selesai | Must |
| FR-10 | Pengguna dapat membuat masalah dan kendala | Must |
| FR-11 | Masalah dapat terhubung ke maksimal satu tahapan | Must |
| FR-12 | Masalah memiliki checkbox selesai | Must |
| FR-13 | Pengguna dapat melihat ide dan masalah berdasarkan tahapan | Must |
| FR-14 | Sistem mencatat aktivitas perubahan secara otomatis | Must |
| FR-15 | Pengguna dapat menyimpan referensi berupa URL | Must |
| FR-16 | Referensi dapat terhubung ke proyek, ide, atau masalah | Must |
| FR-17 | Pengguna dapat menyalin konteks proyek | Must |
| FR-18 | Pengguna dapat menyalin konteks tahapan | Must |
| FR-19 | Pengguna dapat menyalin konteks ide | Must |
| FR-20 | Pengguna dapat menyalin konteks masalah | Must |
| FR-21 | Data tetap tersedia setelah aplikasi ditutup | Must |
| FR-22 | Pengguna dapat mencari proyek | Should |
| FR-23 | Pengguna dapat melakukan backup dan restore JSON | Should |
| FR-24 | Pengguna dapat mengekspor data ke Excel | Future |

## 2.2 Non-Functional Requirements

- Aplikasi dapat digunakan sepenuhnya secara offline.
- Database disimpan di penyimpanan privat aplikasi.
- Tidak membutuhkan login atau registrasi.
- Tidak membutuhkan backend atau API.
- Navigasi harus sederhana dan konsisten.
- Operasi CRUD harus responsif.
- Tidak boleh ada ketergantungan terhadap layanan cloud.
- Data tidak boleh hilang ketika aplikasi ditutup secara normal.
- Perubahan urutan tahapan harus tersimpan secara permanen.

---

# 3. Core Features

## 3.1 Project Management

Halaman utama menampilkan seluruh proyek yang dimiliki pengguna.

Informasi proyek:
- Nama proyek.
- Deskripsi singkat.
- Status proyek: Active, On Hold, Completed, Archived.
- Jumlah tahapan.
- Persentase penyelesaian tahapan.

Fungsi:
- Create Project.
- Edit Project.
- Delete Project.
- Search Project.
- Filter berdasarkan status.

Persentase progres dihitung berdasarkan tahapan yang sudah dicentang dibandingkan seluruh tahapan.

Jika belum memiliki tahapan, tampilkan progres 0% atau status belum dimulai.

## 3.2 Project Description

Setiap proyek memiliki informasi:

- Project Name.
- Description.
- Created At.
- Updated At.

Deskripsi digunakan untuk menjelaskan tujuan, fungsi, dan ruang lingkup proyek.

## 3.3 Milestone / Tahapan

Tahapan merupakan target atau bagian besar dalam pengembangan proyek.

Informasi:
- Nama tahapan.
- Deskripsi.
- Status selesai (checkbox).
- Urutan tahapan.
- Created At.
- Updated At.

Fungsi:
- Create.
- Edit.
- Delete.
- Drag and Drop Sorting.
- Mark as Completed.
- Copy Context.
- View Related Ideas.
- View Related Issues.

Setiap tahapan memiliki detail yang menampilkan:

1. Informasi tahapan.
2. Daftar ide yang terhubung.
3. Daftar masalah yang terhubung.
4. Status penyelesaian masing-masing ide dan masalah.

Urutan tahapan disimpan menggunakan field `sort_order`.

## 3.4 Brainstorming / Ide & Gagasan

Tempat menyimpan seluruh ide pengembangan proyek.

Informasi:
- Judul ide.
- Deskripsi ide.
- Tahapan terkait (opsional).
- Status selesai (checkbox).
- Created At.
- Updated At.

Aturan:
- Ide wajib dimiliki oleh satu proyek.
- Ide boleh tidak memiliki tahapan.
- Jika terhubung, satu ide hanya dapat memiliki satu tahapan.
- Ide yang tidak terhubung tetap muncul pada daftar ide proyek.
- Ide yang selesai tetap tersimpan dan dapat dilihat.
- Ide yang belum selesai dapat dimasukkan ke hasil Copy Context.

## 3.5 Issues / Masalah & Kendala

Tempat mencatat bug, error, kendala teknis, atau masalah pengembangan.

Informasi:
- Judul masalah.
- Deskripsi masalah.
- Tahapan terkait (opsional).
- Status selesai (checkbox).
- Created At.
- Updated At.

Aturan:
- Masalah wajib dimiliki oleh satu proyek.
- Masalah boleh tidak memiliki tahapan.
- Jika terhubung, satu masalah hanya dapat memiliki satu tahapan.
- Masalah yang tidak terhubung tetap muncul pada daftar masalah proyek.
- Masalah yang selesai tetap tersimpan.
- Masalah yang belum selesai dapat dimasukkan ke hasil Copy Context.

## 3.6 Activity Log / Riwayat

Mencatat aktivitas perubahan yang dilakukan pengguna.

Aktivitas yang dicatat:

- Proyek dibuat, diubah, atau dihapus.
- Tahapan dibuat, diubah, dihapus, atau diurutkan ulang.
- Status checkbox tahapan berubah.
- Ide dibuat, diubah, dihapus.
- Status checkbox ide berubah.
- Masalah dibuat, diubah, dihapus.
- Status checkbox masalah berubah.
- Referensi dibuat, diubah, atau dihapus.

Format informasi:

- Nama aktivitas.
- Jenis aktivitas.
- Deskripsi perubahan.
- Waktu aktivitas.

Contoh:
- Menambahkan tahapan "Authentication".
- Menyelesaikan tahapan "Dashboard".
- Menambahkan ide "Google Login".
- Menandai masalah "Validasi Upload" sebagai selesai.
- Mengubah urutan tahapan.

Log dibuat secara otomatis ketika operasi berhasil disimpan.

Riwayat hanya berfungsi sebagai dokumentasi aktivitas, bukan sebagai sistem undo atau version control.

## 3.7 References / Referensi

Tempat menyimpan tautan yang berkaitan dengan proyek.

Informasi:
- Judul referensi.
- URL.
- Catatan singkat (opsional).
- Proyek terkait.
- Ide terkait (opsional).
- Masalah terkait (opsional).

Aturan:
- Referensi wajib dimiliki satu proyek.
- Referensi boleh berdiri sendiri.
- Referensi boleh terhubung dengan satu ide atau satu masalah.
- Satu referensi tidak boleh terhubung ke ide dan masalah sekaligus.
- Referensi dapat dibuka melalui browser eksternal.
- Referensi terkait dapat ditampilkan pada detail ide atau masalah.

## 3.8 Copy Context / Salin Konteks

Merupakan fitur utama aplikasi untuk menghasilkan teks terstruktur yang dapat langsung disalin ke clipboard.

Tidak memerlukan integrasi AI API.

### A. Copy Project

Konten:
- Nama proyek.
- Deskripsi proyek.
- Seluruh tahapan.
- Ide yang belum selesai.
- Masalah yang belum selesai.
- Nama tahapan terkait untuk setiap ide dan masalah.
- Referensi relevan jika diperlukan.

Ide dan masalah ditampilkan berdasarkan tahapan masing-masing. Data yang tidak terhubung dengan tahapan ditampilkan pada bagian tersendiri.

### B. Copy Milestone

Konten:
- Nama proyek.
- Deskripsi proyek.
- Nama tahapan.
- Deskripsi tahapan.
- Ide yang belum selesai dan terhubung ke tahapan tersebut.
- Masalah yang belum selesai dan terhubung ke tahapan tersebut.
- Referensi terkait jika ada.

### C. Copy Idea

Konten:
- Nama proyek.
- Deskripsi proyek.
- Nama tahapan jika terhubung.
- Judul ide.
- Deskripsi ide.
- Referensi yang terhubung jika ada.

### D. Copy Issue

Konten:
- Nama proyek.
- Deskripsi proyek.
- Nama tahapan jika terhubung.
- Judul masalah.
- Deskripsi masalah.
- Referensi yang terhubung jika ada.

### Copy Context Rules

- Hanya data yang belum dicentang yang dimasukkan untuk daftar ide dan masalah.
- Tahapan tetap dapat disalin meskipun sudah dicentang.
- Informasi yang tidak tersedia tidak perlu ditampilkan sebagai teks kosong.
- Format harus bersih, terstruktur, dan mudah dipahami AI.
- Setelah berhasil disalin, tampilkan notifikasi singkat "Berhasil disalin".
- Proses copy tidak boleh mengubah data database.

---

# 4. User Flow

## 4.1 Main Flow

1. Pengguna membuka aplikasi.
2. Sistem menampilkan daftar proyek.
3. Pengguna memilih proyek.
4. Sistem menampilkan detail proyek.
5. Pengguna memilih salah satu menu.
6. Pengguna melakukan pencatatan atau perubahan.
7. Sistem menyimpan data.
8. Sistem mencatat aktivitas ke Riwayat.

## 4.2 Create Project Flow

1. Klik tombol tambah proyek.
2. Masukkan nama proyek.
3. Masukkan deskripsi.
4. Simpan.
5. Proyek muncul di daftar utama.

## 4.3 Milestone Flow

1. Masuk ke detail proyek.
2. Pilih Tahapan.
3. Tambahkan tahapan.
4. Masukkan nama dan deskripsi.
5. Simpan.
6. Tahapan muncul pada daftar.
7. Pengguna dapat mengubah urutan dengan drag and drop.
8. Pengguna dapat mencentang tahapan ketika selesai.
9. Pengguna dapat membuka detail tahapan untuk melihat ide dan masalah terkait.

## 4.4 Brainstorming Flow

1. Masuk ke detail proyek.
2. Pilih Ide & Gagasan.
3. Tambahkan ide.
4. Masukkan judul dan deskripsi.
5. Pilih tahapan (opsional).
6. Simpan.
7. Ide muncul pada daftar proyek dan detail tahapan jika terhubung.
8. Pengguna dapat mencentang ide ketika selesai.

## 4.5 Issue Flow

Alurnya sama dengan Brainstorming, tetapi digunakan untuk mencatat masalah dan kendala.

## 4.6 Reference Flow

1. Masuk ke Referensi.
2. Tambahkan referensi.
3. Masukkan judul dan URL.
4. Tambahkan catatan jika diperlukan.
5. Pilih hubungan: proyek saja, ide, atau masalah.
6. Simpan.

## 4.7 Copy Context Flow

1. Pengguna membuka proyek, tahapan, ide, atau masalah.
2. Menekan tombol Copy.
3. Sistem mengambil data yang relevan.
4. Sistem memfilter ide dan masalah yang belum selesai sesuai aturan scope.
5. Sistem menyusun teks.
6. Sistem menyalin teks ke clipboard.
7. Pengguna menempelkan hasilnya ke AI coding tool.

---

# 5. Architecture

## 5.1 Architecture Principles

Menggunakan arsitektur sederhana dan terpisah berdasarkan tanggung jawab.

Hindari overengineering, dependency injection framework yang kompleks, dan lapisan abstraksi yang tidak diperlukan.

## 5.2 Application Architecture

```text
Flutter Application
│
├── Presentation Layer
│   ├── Screens
│   ├── Widgets
│   └── UI State
│
├── Data Layer
│   ├── Models
│   ├── Database Helper
│   └── Repositories
│
├── Services
│   ├── Copy Context Service
│   ├── Activity Log Service
│   └── Excel Export Service (Future)
│
└── Local Database
    └── SQLite
```

## 5.3 Data Flow

```text
User Interaction
       │
       ▼
Flutter Screen
       │
       ▼
Repository
       │
       ▼
Database Helper
       │
       ▼
SQLite Database
       │
       ▼
Return Data
       │
       ▼
Update UI
```

## 5.4 Activity Log Handling

Setiap operasi perubahan data dan pencatatan log harus dilakukan dalam satu database transaction jika memungkinkan.

Jika penyimpanan data gagal, log perubahan tidak boleh tercatat sebagai aktivitas berhasil.

## 5.5 Local Storage

- Database berada di direktori privat aplikasi.
- Database menggunakan SQLite.
- Tidak membutuhkan koneksi internet.
- Database memiliki versioning melalui `PRAGMA user_version`.
- Perubahan struktur database dilakukan menggunakan migration.

---

# 6. Database Schema

Database name: `project_tracker.db`

Semua tabel menggunakan SQLite.

## 6.1 projects

| Field | Type | Description |
|---|---|---|
| id | INTEGER PK | Primary Key |
| name | TEXT | Nama proyek |
| description | TEXT | Deskripsi |
| status | TEXT | active, on_hold, completed, archived |
| created_at | TEXT | Waktu dibuat |
| updated_at | TEXT | Waktu diperbarui |

## 6.2 milestones

| Field | Type | Description |
|---|---|---|
| id | INTEGER PK | Primary Key |
| project_id | INTEGER FK | Relasi proyek |
| name | TEXT | Nama tahapan |
| description | TEXT | Deskripsi tahapan |
| is_completed | INTEGER | 0 atau 1 |
| sort_order | INTEGER | Urutan tahapan |
| created_at | TEXT | Waktu dibuat |
| updated_at | TEXT | Waktu diperbarui |

## 6.3 brainstorms

| Field | Type | Description |
|---|---|---|
| id | INTEGER PK | Primary Key |
| project_id | INTEGER FK | Relasi proyek |
| milestone_id | INTEGER FK NULL | Relasi tahapan opsional |
| title | TEXT | Judul ide |
| description | TEXT | Deskripsi ide |
| is_completed | INTEGER | 0 atau 1 |
| created_at | TEXT | Waktu dibuat |
| updated_at | TEXT | Waktu diperbarui |

## 6.4 issues

| Field | Type | Description |
|---|---|---|
| id | INTEGER PK | Primary Key |
| project_id | INTEGER FK | Relasi proyek |
| milestone_id | INTEGER FK NULL | Relasi tahapan opsional |
| title | TEXT | Judul masalah |
| description | TEXT | Deskripsi masalah |
| is_completed | INTEGER | 0 atau 1 |
| created_at | TEXT | Waktu dibuat |
| updated_at | TEXT | Waktu diperbarui |

## 6.5 references

| Field | Type | Description |
|---|---|---|
| id | INTEGER PK | Primary Key |
| project_id | INTEGER FK | Relasi proyek |
| brainstorm_id | INTEGER FK NULL | Relasi ide opsional |
| issue_id | INTEGER FK NULL | Relasi masalah opsional |
| title | TEXT | Judul referensi |
| url | TEXT | URL referensi |
| notes | TEXT NULL | Catatan tambahan |
| created_at | TEXT | Waktu dibuat |
| updated_at | TEXT | Waktu diperbarui |

Constraint:
- brainstorm_id dan issue_id tidak boleh terisi bersamaan.
- Keduanya boleh NULL.
- Relasi ide dan masalah harus berasal dari proyek yang sama.

## 6.6 activity_logs

| Field | Type | Description |
|---|---|---|
| id | INTEGER PK | Primary Key |
| project_id | INTEGER FK | Relasi proyek |
| entity_type | TEXT | project, milestone, brainstorm, issue, reference |
| entity_id | INTEGER NULL | ID data terkait |
| action | TEXT | create, update, delete, complete, reorder |
| description | TEXT | Keterangan aktivitas |
| created_at | TEXT | Waktu aktivitas |

Activity log menyimpan ringkasan aktivitas dalam bentuk teks agar riwayat tetap dapat dibaca meskipun data terkait sudah dihapus.

## 6.7 Database Relationships

```text
projects
  │
  ├── milestones
  │      │
  │      ├── brainstorms (optional milestone_id)
  │      └── issues (optional milestone_id)
  │
  ├── brainstorms
  ├── issues
  ├── references
  └── activity_logs

references
  ├── brainstorm_id (optional)
  └── issue_id (optional)
```

## 6.8 Database Rules

- Semua tabel memiliki primary key.
- Foreign key harus diaktifkan.
- Gunakan ON DELETE CASCADE untuk data anak yang memang harus ikut terhapus.
- Hapus proyek akan menghapus seluruh data turunannya.
- Sebelum menghapus entitas, buat activity log terlebih dahulu.
- Hapus tahapan tidak otomatis menghapus ide atau masalah. Set `milestone_id` menjadi NULL.
- Hapus ide atau masalah tidak menghapus referensi yang terhubung. Referensi dikembalikan menjadi referensi proyek.
- Semua waktu disimpan dalam format ISO 8601.
- Checkbox menggunakan INTEGER dengan nilai 0 dan 1.
- Perubahan sort_order dilakukan dalam satu transaksi.

---

# 7. Tech Stack

Prinsip utama: menggunakan teknologi yang sederhana, stabil, dan minim dependency.

| Component | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Database | SQLite |
| Database Package | sqflite |
| Path Management | path |
| UI | Flutter Material 3 |
| State Management | setState / StatefulWidget |
| Navigation | Navigator bawaan Flutter |
| Clipboard | Flutter Services API |
| Reorder | ReorderableListView bawaan Flutter |
| Date Formatting | intl |
| Excel Export (Future) | excel package |
| File Sharing (Future) | share_plus |
| Build | Flutter Build APK / AAB |

## 7.1 Dependency Policy

Hindari penggunaan plugin jika fitur sudah tersedia di Flutter SDK.

Prioritaskan:
- Clipboard menggunakan `Clipboard.setData`.
- Drag and drop menggunakan `ReorderableListView`.
- Navigasi menggunakan Navigator.
- State sederhana menggunakan StatefulWidget dan setState.
- Database menggunakan sqflite.

Tidak perlu menggunakan:
- Firebase.
- Supabase.
- REST API.
- Authentication.
- Cloud storage.
- AI API.
- Dependency Injection Framework.
- State Management Framework yang kompleks.

## 7.2 Future Export

Fitur export Excel akan dikembangkan setelah MVP stabil.

Rencana struktur workbook:

**Sheet 1 — Ringkasan Proyek**
- Nama proyek.
- Deskripsi.
- Status.
- Total tahapan.
- Tahapan selesai.
- Persentase progres.

**Sheet 2 — Tahapan**
- Nomor.
- Nama tahapan.
- Deskripsi.
- Status.
- Urutan.

**Sheet 3 — Ide & Gagasan**
- Nomor.
- Judul ide.
- Deskripsi.
- Tahapan terkait.
- Status.

**Sheet 4 — Masalah**
- Nomor.
- Judul masalah.
- Deskripsi.
- Tahapan terkait.
- Status.

**Sheet 5 — Referensi**
- Judul.
- URL.
- Catatan.
- Ide terkait.
- Masalah terkait.

**Sheet 6 — Riwayat**
- Waktu.
- Jenis aktivitas.
- Keterangan.

Workbook harus mudah dibaca pengguna umum, menggunakan header yang jelas, filter, freeze header, dan lebar kolom yang sesuai.

---

# 8. Design Guidelines

## 8.1 Design Philosophy

Minimalist, clean, modern, dan productivity-focused.

Aplikasi hanya menggunakan dark mode.

Hindari:
- Warna terlalu banyak.
- Gradient berlebihan.
- Shadow berlebihan.
- Animasi yang tidak diperlukan.
- Komponen dekoratif yang tidak memiliki fungsi.
- Dashboard yang terlalu padat.

## 8.2 Color Palette

Gunakan palet dark dengan satu warna aksen.

| Element | Color |
|---|---|
| Background | #121212 |
| Surface | #1C1C1E |
| Surface Elevated | #252528 |
| Primary Accent | #8B9CF6 |
| Primary Text | #F5F5F5 |
| Secondary Text | #A1A1AA |
| Border | #343438 |
| Success | #81C995 |
| Warning | #E9B96E |
| Error | #E98282 |

Warna status hanya digunakan seperlunya. Jangan memberikan warna berbeda pada setiap menu.

## 8.3 Typography

- Gunakan font bawaan sistem atau font sans-serif sederhana.
- Judul jelas dan mudah dibaca.
- Body text nyaman untuk layar HP.
- Hindari ukuran font terlalu kecil.
- Gunakan hierarchy ukuran dan ketebalan font secara konsisten.

## 8.4 UI Components

Prioritaskan:
- Card sederhana.
- List item.
- Checkbox.
- Dialog.
- Bottom sheet.
- Floating Action Button.
- Search field.
- Tab atau menu navigasi sederhana.
- Empty state.

## 8.5 Navigation Structure

Bottom navigation yang disarankan:

1. Proyek.
2. Riwayat (opsional sebagai menu global jika dibutuhkan).

Menu lainnya berada dalam halaman Detail Proyek.

Detail proyek menggunakan tab atau daftar menu yang sederhana.

## 8.6 Interaction Guidelines

- Form tambah/edit menggunakan dialog atau bottom sheet.
- Checkbox dapat diubah langsung tanpa membuka detail.
- Drag and drop memberikan feedback visual yang jelas.
- Tombol Copy mudah ditemukan.
- Penghapusan data memerlukan konfirmasi.
- Berikan snackbar untuk feedback berhasil/gagal.
- Tampilkan empty state dengan ajakan menambahkan data.

---

# 9. Development Process Flow

Pengembangan dilakukan bertahap untuk menghindari banyak bug dan mempermudah AI-assisted coding.

Setiap fase harus selesai dan diuji sebelum melanjutkan fase berikutnya.

## Phase 1 — Project Foundation

- Inisialisasi proyek Flutter.
- Setup struktur folder.
- Setup tema dark.
- Setup navigasi dasar.
- Setup SQLite.
- Setup database migration.
- Implementasi database helper.

Acceptance Criteria:
- Aplikasi dapat dijalankan.
- Database dapat dibuat.
- Database dapat diakses.
- Dark mode berjalan konsisten.

## Phase 2 — Project Management

- Halaman daftar proyek.
- Tambah proyek.
- Edit proyek.
- Hapus proyek.
- Search proyek.
- Status proyek.
- Detail proyek.

Acceptance Criteria:
- CRUD berjalan.
- Data tersimpan di SQLite.
- Data tidak hilang setelah aplikasi ditutup.
- Navigasi antarhalaman berjalan.

## Phase 3 — Milestone Management

- CRUD tahapan.
- Checkbox selesai.
- Drag and drop sorting.
- Detail tahapan.
- Menampilkan ide dan masalah terkait.
- Progress proyek.

Acceptance Criteria:
- Urutan tahapan tersimpan.
- Checkbox tersimpan.
- Detail tahapan menampilkan data yang sesuai.

## Phase 4 — Brainstorming & Issues

- CRUD ide.
- CRUD masalah.
- Relasi opsional ke tahapan.
- Checkbox selesai.
- Filter berdasarkan tahapan.
- Tampilan data tanpa tahapan.

Acceptance Criteria:
- Ide dan masalah dapat dibuat tanpa tahapan.
- Relasi maksimal satu tahapan.
- Checkbox berjalan.
- Data dapat ditampilkan berdasarkan proyek maupun tahapan.

## Phase 5 — References

- CRUD referensi.
- Validasi URL.
- Relasi opsional ke ide atau masalah.
- Membuka URL melalui aplikasi eksternal.
- Menampilkan referensi terkait.

Acceptance Criteria:
- Referensi dapat berdiri sendiri.
- Referensi dapat terhubung dengan ide atau masalah.
- Referensi tidak dapat terhubung ke keduanya sekaligus.

## Phase 6 — Activity Log

- Pencatatan otomatis aktivitas.
- Tampilan riwayat.
- Format waktu.
- Log create, update, delete, complete, dan reorder.

Acceptance Criteria:
- Aktivitas tercatat setelah perubahan berhasil.
- Log tidak tercatat jika transaksi gagal.
- Riwayat tetap dapat dibaca setelah entitas dihapus.

## Phase 7 — Copy Context

- Copy Project.
- Copy Milestone.
- Copy Idea.
- Copy Issue.
- Format teks terstruktur.
- Filter data belum selesai.
- Sertakan referensi terkait.
- Feedback snackbar.

Acceptance Criteria:
- Hasil copy sesuai scope.
- Tidak memasukkan ide dan masalah yang sudah selesai.
- Nama proyek dan deskripsi selalu tersedia.
- Nama tahapan hanya muncul jika relevan.
- Hasil dapat ditempel ke aplikasi lain.

## Phase 8 — Testing & Stabilization

- Uji seluruh CRUD.
- Uji relasi foreign key.
- Uji checkbox.
- Uji drag and drop.
- Uji activity log.
- Uji Copy Context.
- Uji data kosong.
- Uji penghapusan data.
- Uji database migration.
- Uji penggunaan tanpa internet.
- Perbaikan bug.
- Build APK release.

Acceptance Criteria:
- Tidak ada bug kritis.
- Semua fitur MVP berjalan.
- Data tetap konsisten.
- Aplikasi stabil digunakan sehari-hari.

## Phase 9 — Future Development

Dikerjakan setelah MVP stabil:

1. Export Excel multi-sheet.
2. Import Excel jika memang dibutuhkan.
3. Backup dan restore JSON.
4. Peningkatan UX.
5. Statistik proyek sederhana.
6. Fitur pencarian global.

---

# Final Development Rules

1. Jangan menambahkan fitur di luar PRD tanpa evaluasi terlebih dahulu.
2. Jangan mengubah struktur database tanpa migration.
3. Jangan membuat duplikasi fungsi atau komponen.
4. Gunakan widget yang dapat digunakan ulang jika memang diperlukan.
5. Hindari abstraksi berlebihan.
6. Selesaikan satu fase sebelum melanjutkan fase berikutnya.
7. Setiap fitur wajib diuji sebelum dianggap selesai.
8. Utamakan stabilitas dan konsistensi data.
9. Jangan menambahkan dependency baru jika Flutter SDK sudah menyediakan fungsi serupa.
10. Pertahankan desain minimalis dan dark mode.

**Product Success Criteria:**

Pengguna dapat membuat proyek, mencatat tahapan, mengelola ide dan masalah, menyimpan referensi, melihat riwayat, serta menyalin konteks pengembangan ke AI coding tool dengan cepat tanpa koneksi internet.