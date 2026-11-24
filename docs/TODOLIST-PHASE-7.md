# TODOLIST — Phase 7: Copy Context

> **Tujuan:** Implementasi fitur utama Copy Context — menyusun dan menyalin konteks proyek, tahapan, ide, atau masalah ke clipboard sebagai prompt teks terstruktur yang optimal untuk digunakan pada AI coding tools (LLM), tanpa memerlukan integrasi AI API eksternal.  
> **Prasyarat:** Phase 6 selesai (Activity Log aktif dan teruji).  
> **Status:** 🔲 Belum Dimulai

---

## 1. Services Layer — Copy Context Engine

Folder: `lib/services/`

- [ ] `1.1` Buat `CopyContextService` di `services/copy_context_service.dart`
  - [ ] `generateProjectContext(int projectId)` → String teks prompt terstruktur:
    - Nama & Deskripsi Proyek
    - Daftar Tahapan (lengkap dengan urutan & status selesai)
    - Ide & Gagasan yang **belum selesai**, dikelompokkan berdasarkan tahapan (dan bagian terpisah untuk ide tanpa tahapan)
    - Masalah & Kendala yang **belum selesai**, dikelompokkan berdasarkan tahapan (dan bagian terpisah untuk masalah tanpa tahapan)
    - Tautan Referensi relevan
  - [ ] `generateMilestoneContext(int milestoneId)` → String teks prompt terstruktur:
    - Nama & Deskripsi Proyek
    - Nama & Deskripsi Tahapan terkait
    - Ide yang belum selesai pada tahapan tersebut
    - Masalah yang belum selesai pada tahapan tersebut
    - Referensi relevan jika ada
  - [ ] `generateBrainstormContext(int brainstormId)` → String teks prompt terstruktur:
    - Nama & Deskripsi Proyek
    - Nama Tahapan (jika terhubung)
    - Judul & Deskripsi Ide
    - Tautan Referensi yang terhubung
  - [ ] `generateIssueContext(int issueId)` → String teks prompt terstruktur:
    - Nama & Deskripsi Proyek
    - Nama Tahapan (jika terhubung)
    - Judul & Deskripsi Masalah
    - Tautan Referensi yang terhubung
  - [ ] Helper `copyToClipboard(BuildContext context, String text, {String successMessage = 'Konteks berhasil disalin ke clipboard'})`:
    - Menggunakan `Clipboard.setData(ClipboardData(text: text))`
    - Menampilkan notifikasi visual SnackBar umpan balik yang ramah

---

## 2. Presentation Layer — Integration

- [ ] `2.1` Integrasi `ProjectDetailScreen`:
  - Tambahkan tombol / aksi AppBar "Salin Konteks Proyek" (ikon `Icons.copy_all` atau `Icons.content_copy`)
  - Eksekusi `generateProjectContext()` dan salin ke clipboard dengan notifikasi snackbar
- [ ] `2.2` Integrasi `MilestoneDetailScreen`:
  - Tambahkan tombol aksi "Salin Konteks Tahapan"
  - Eksekusi `generateMilestoneContext()` dan salin ke clipboard
- [ ] `2.3` Integrasi `BrainstormDetailScreen`:
  - Tambahkan tombol aksi "Salin Konteks Ide"
  - Eksekusi `generateBrainstormContext()` dan salin ke clipboard
- [ ] `2.4` Integrasi `IssueDetailScreen`:
  - Tambahkan tombol aksi "Salin Konteks Masalah"
  - Eksekusi `generateIssueContext()` dan salin ke clipboard

---

## 3. Copy Context Formatting & LLM Prompt Rules

- [ ] `3.1` Filter Ketat:
  - Hanya data ide dan masalah yang **belum selesai (is_completed == 0)** yang dimasukkan ke konteks
  - Tahapan tetap dimasukkan lengkap dengan status penyelesaian
- [ ] `3.2` Format Output Terstruktur:
  - Header jelas dengan Markdown (`# Proyek`, `## Tahapan`, `### Ide Aktif`, `### Kendala Aktif`, `### Referensi Terkait`)
  - Tidak memuat placeholder teks kosong (bagian yang kosong otomatis dilewati dengan bersih)
  - Desain prompt siap pakai dan langsung dipahami oleh AI coding assistant (Cursor, Gemini CLI, Claude, ChatGPT, dll.)

---

## 4. Verifikasi & Acceptance Criteria

- [ ] `4.1` Hasil copy sesuai dengan scope yang dipilih (Proyek, Tahapan, Ide, atau Masalah)
- [ ] `4.2` Ide dan masalah yang sudah selesai **tidak pernah** dimasukkan ke hasil copy
- [ ] `4.3` Nama dan deskripsi proyek selalu ada di seluruh level konteks
- [ ] `4.4` Nama tahapan hanya muncul jika relevan
- [ ] `4.5` Referensi terhubung disertakan dengan benar
- [ ] `4.6` Teks berhasil tersimpan di sistem clipboard dan menampilkan SnackBar sukses
- [ ] `4.7` Proses copy adalah read-only (tidak mengubah database sama sekali)
- [ ] `4.8` Unit test `CopyContextService` & widget tests lulus
- [ ] `4.9` `flutter analyze` 100% bersih tanpa issue
- [ ] `4.10` Commit ke `main`: `feat: phase 7 - copy context`

---

## Aturan Kerja Phase 7

> Fitur murni berbasis data lokal SQLite dan clipboard, tanpa ketergantungan API pihak ketiga.  
> Format teks wajib rapi, ringkas, dan fokus pada actionable items untuk AI assistant.  
> Semua pesan umpan balik menggunakan Bahasa Indonesia natural (*human Indo*).

---

*Referensi: [PRD.md](./PRD.md) — Section 3.8, 4.7, 9 (Phase 7)*
