# TODOLIST — Phase 8: Testing & Stabilization

> **Tujuan:** Pengujian menyeluruh (*end-to-end regression & smoke testing*), audit integritas data SQLite, validasi performa, verifikasi perilaku offline penuh, perbaikan bug minor/edge cases, dan kesiapan rilis APK production.  
> **Prasyarat:** Phase 1 hingga Phase 7 selesai (seluruh fitur inti MVP terimplementasi).  
> **Status:** ✅ Selesai

---

## 1. Regression & Data Integrity Testing

- [x] `1.1` Audit Skema & Relasi Database SQLite:
  - Verifikasi tabel: `projects`, `milestones`, `brainstorms`, `issues`, `references`, `activity_logs`
  - Verifikasi integritas Foreign Keys (`PRAGMA foreign_keys = ON`)
  - Verifikasi `ON DELETE CASCADE`:
    - Menghapus proyek menghapus seluruh tahapan, ide, masalah, referensi, dan activity logs
  - Verifikasi `ON DELETE SET NULL`:
    - Menghapus tahapan melepaskan relasi `milestone_id` pada ide dan masalah menjadi NULL tanpa menghilangkan datanya
  - Verifikasi aturan referensi:
    - Referensi tidak boleh memiliki `brainstorm_id` dan `issue_id` secara bersamaan
    - Menghapus ide/masalah mengembalikan referensi terkait menjadi referensi mandiri proyek

- [x] `1.2` Audit Alur Bisnis & State Management:
  - Project CRUD, pencarian, dan pemfilteran status (`active`, `onHold`, `completed`, `archived`)
  - Milestone reorder (drag & drop urutan) dalam transaksi SQLite
  - Milestone progress bar perhitungan persentase secara real-time
  - Brainstorm & Issue checkbox penyelesaian langsung dari daftar tanpa membuka form
  - Reference URL validasi skema (`http://` / `https://`) dan eksekusi launcher
  - Activity log pencatatan otomatis di semua modul dan linimasa waktu relatif
  - Copy Context di seluruh 4 level (Project, Milestone, Brainstorm, Issue) dengan filter ketat item aktif

---

## 2. Offline & Edge Cases Verification

- [x] `2.1` Verifikasi Kemandirian Offline (No Internet):
  - Memastikan seluruh fitur aplikasi dapat beroperasi normal tanpa koneksi internet
  - Tidak ada dependensi ke cloud API, auth eksternal, atau telemetry
- [x] `2.2` Uji Kondisi Batas (Edge Cases):
  - Proyek/tahapan tanpa deskripsi (string kosong)
  - Copy context pada proyek tanpa tahapan, tanpa ide, atau tanpa masalah (bebas placeholder kosong)
  - Karakter khusus pada teks (tanda petik, emoji, baris baru, simbol markdown)
  - Input teks panjang pada deskripsi dan catatan referensi
  - Navigasi bolak-balik cepat (*rapid popping / pushing*) tidak menyebabkan memory leak atau unmounted state error

---

## 3. UI/UX & Code Quality Polish

- [x] `3.1` Audit Desain & Dark Palette:
  - Memastikan seluruh screen konsisten menggunakan token tema [theme.dart](../lib/core/theme.dart)
  - Skala tipografi konsisten 15, 12, 10 di seluruh layar
  - Tombol seragam berbasis fungsi: Teks saja atau ikon saja (tidak dicampur)
  - Form input seragam: radius 10, hintText informatif, warna permukaan tema
  - Seluruh teks visual menggunakan Human Indo (singkat, jelas, tegas)
- [x] `3.2` Audit Kualitas Kode & Analisis Statis:
  - Jalankan `flutter analyze` dan pastikan 0 issues (0 warning, 0 error, 0 hint)
  - Jalankan seluruh suite `flutter test` dan pastikan seluruh test lulus (84/84 tests passed)

---

## 4. Build & Production Readiness

- [x] `4.1` Validasi Build APK & Manifest:
  - Konfigurasi `AndroidManifest.xml` diperbarui dengan label aplikasi `"Personal Project Tracker"`
  - Intent queries untuk skema URL `https` dan `http` dikonfigurasi untuk Android 11+
- [x] `4.2` Dokumentasi & Release Tagging:
  - Perbarui [README.md](../README.md) dengan ringkasan status MVP siap rilis
  - Tandai Phase 8 selesai
  - Commit ke `main`: `feat: phase 8 - testing and stabilization`

---

## Aturan Kerja Phase 8

> Fokus pada stabilitas, keandalan data, dan penyempurnaan kualitas tanpa menambah fitur di luar PRD.  
> Seluruh string umpan balik dan dialog tetap konsisten dalam Bahasa Indonesia natural (*human Indo*).

---

*Referensi: [PRD.md](./PRD.md) — Section 8, 9 (Phase 8), Final Development Rules*
