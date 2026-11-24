# TODOLIST — Phase 6: Activity Log

> **Tujuan:** Implementasi modul pencatatan riwayat perubahan (Activity Log) otomatis — mencatat pembuatan, perubahan, penghapusan, status penyelesaian, dan penyusunan ulang urutan pada proyek, tahapan, ide, masalah, dan referensi, serta menampilkan linimasa riwayat yang informatif dan mudah dibaca.  
> **Prasyarat:** Phase 5 selesai (Modul References aktif dan terhubung).  
> **Status:** ✅ Selesai

---

## 1. Data Layer — Models

- [x] `1.1` Buat `ActivityLogModel` di `data/models/activity_log_model.dart`
  - Field:
    - `id` (int? nullable)
    - `projectId` (int)
    - `entityType` (String: `project`, `milestone`, `brainstorm`, `issue`, `reference`)
    - `entityId` (int? nullable)
    - `action` (String: `create`, `update`, `delete`, `complete`, `reorder`)
    - `description` (String, teks human-friendly dalam Bahasa Indonesia)
    - `createdAt` (DateTime)
  - Helper getters:
    - Icon & warna representatif per jenis aksi/entitas
  - Method: `fromMap()`, `toMap()`, `copyWith()`

---

## 2. Data Layer — Repositories

- [x] `2.1` Buat `ActivityLogRepository` di `data/repositories/activity_log_repository.dart`
  - [x] `insertLog(ActivityLogModel log)` → return id
  - [x] `log({required int projectId, required String entityType, required String action, required String description, int? entityId})` → helper pencatatan instan
  - [x] `getLogsByProjectId(int projectId, {String? entityType, int limit = 100})` → return `List<ActivityLogModel>` (terurut dari yang terbaru)
  - [x] `getLogCountByProject(int projectId)` → hitung total catatan aktivitas
  - [x] `clearLogsByProject(int projectId)` → opsi membersihkan riwayat proyek

---

## 3. Services / Auto-logging Integration

- [x] `3.1` Integrasikan pencatatan riwayat otomatis saat operasi database berhasil:
  - **Tahapan:** Ditambahkan, diperbarui, dihapus, status selesai dicentang/dibatalkan, diurutkan ulang
  - **Ide:** Ditambahkan, diperbarui, dihapus, status selesai dicentang/dibatalkan
  - **Kendala:** Dicatat, diperbarui, dihapus, status selesai dicentang/dibatalkan
  - **Referensi:** Ditambahkan, diperbarui, dihapus
  - **Proyek:** Status diperbarui atau diedit
- [x] `3.2` Pastikan log tetap tersimpan meskipun entitas asli dihapus (`entity_id` opsional, data riwayat tidak hilang)

---

## 4. Presentation — Activity Log (Riwayat Aktivitas)

Folder: `presentation/screens/activity_logs/`

- [x] `4.1` Buat `ActivityLogScreen`:
  - Linimasa (timeline) vertikal yang rapi dan elegan
  - Filter Chips: Semua Riwayat, Tahapan, Ide, Kendala, Referensi, Proyek
  - Item tampilan kartu timeline:
    - Icon status/tipe yang sesuai (misal: centang hijau untuk selesai, pensil untuk edit, tempat sampah untuk hapus)
    - Deskripsi perubahan yang informatif dalam Bahasa Indonesia
    - Waktu aktivitas (format relatif ramah pengguna seperti "Baru saja", "10 menit lalu", atau tanggal lengkap)
  - Empty state ramah pengguna jika belum ada riwayat tercatat

---

## 5. Integration — Detail Screens

- [x] `5.1` Integrasi `ProjectDetailScreen`:
  - Hubungkan kartu navigasi "Riwayat Aktivitas" ke `ActivityLogScreen`
  - Tampilkan jumlah riwayat aktivitas di subtitle kartu secara real-time (`X Aktivitas`)

---

## 6. Verifikasi & Acceptance Criteria

- [x] `6.1` Aktivitas otomatis tercatat di SQLite setiap operasi data berhasil disimpan
- [x] `6.2` Log tidak tercatat jika operasi transaksi gagal
- [x] `6.3` Riwayat tetap dapat dibaca dengan jelas setelah entitas terkait dihapus
- [x] `6.4` Menghapus proyek menghapus seluruh riwayat log terkait (`CASCADE`)
- [x] `6.5` `flutter analyze` 100% bersih tanpa issue
- [x] `6.6` Unit test repository & widget test presentation lulus
- [x] `6.7` Commit ke `main`: `feat: phase 6 - activity log`

---

## Aturan Kerja Phase 6

> Fokus pada Activity Log: Dokumentasi otomatis aktivitas pengguna, bukan sistem undo/revert.  
> Format teks log wajib natural dalam Bahasa Indonesia (human Indo).  
> Desain timeline clean & minimalis sesuai tema Dark Palette bawaan PRD.

---

*Referensi: [PRD.md](./PRD.md) — Section 3.6, 4.7, 8.5, 9 (Phase 6)*
