# PANDUAN STANDAR UI/UX (UI-RULE)

Dokumen ini merupakan acuan tunggal dan standar baku tampilan visual antarmuka (*UI/UX Design Standard*) untuk seluruh layar, dialog, dan komponen pada aplikasi **Personal Project Tracker**.

---

## 1. Skala Tipografi (Typography Scale: 15 / 12 / 10)

Untuk menjaga konsistensi visual dan kenyamanan membaca pada tema gelap (*Dark Mode*), seluruh teks dalam aplikasi wajib mengacu pada 3 tingkat ukuran font:

| Tingkat | Ukuran (sp/px) | Bobot (*Weight*) | Warna | Penggunaan Khusus |
|---|---|---|---|---|
| **Tier 1 (Header/Title)** | **15** | `FontWeight.bold` (w700) / `w600` | `AppColors.primaryText` (`#F5F5F5`) | Judul AppBar, Judul Card Utama, Judul Dialog / BottomSheet, Judul Empty State |
| **Tier 2 (Body/Action)** | **12** | `FontWeight.w500` / `normal` (w400) | `AppColors.primaryText` / `AppColors.secondaryText` | Isi teks deskripsi, isi teks input field & dropdown, label button (FilledButton/TextButton), label chip filter, subtitle AppBar |
| **Tier 3 (Caption/Badge)** | **10** | `FontWeight.w600` (badge) / `w400` | `AppColors.secondaryText` (`#A1A1AA`) / Status Color | Timestamp waktu relatif ("Baru saja", "5 menit lalu"), Badge status (pill kecil), counter metadata ("3 Tahapan"), catatan kecil |

> **Catatan:** Hindari penggunaan ukuran font di luar 15, 12, dan 10 (seperti 18, 16, 14, 13, 11) agar hierarki tampilan selalu rapi dan konsisten.

---

## 2. Standar Tombol (Button Visual Consistency)

Prinsip utama tombol: **PILIH SALAH SATU: HANYA TEKS ATAU HANYA IKON** (jangan menggabungkan teks dan ikon dalam satu tombol karena fungsi tombol sudah jelas dan harus tetap simpel).

### A. Tombol Berbasis Teks (Text Only)
Digunakan pada formulir, dialog, dan aksi utama di layar:

1. **Aksi Positif / Utama (Simpan, Buat, Tambah, Terapkan):**
   - Komponen: `FilledButton`
   - Warna Latar: `AppColors.primaryAccent` (`#8B9CF6`)
   - Warna Teks: `AppColors.background` (`#121212`) — kontras tinggi
   - Ukuran Font: `12` (`FontWeight.bold` / `w600`)
   - Bentuk: `RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))`

2. **Aksi Destruktif (Hapus, Bersihkan):**
   - Komponen: `FilledButton`
   - Warna Latar: `AppColors.error` (`#E98282`)
   - Warna Teks: `AppColors.primaryText` (`#F5F5F5`)
   - Ukuran Font: `12` (`FontWeight.bold` / `w600`)
   - Bentuk: `RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))`

3. **Aksi Sekunder / Batal (Batal, Tutup, Kembali):**
   - Komponen: `TextButton`
   - Warna Teks: `AppColors.secondaryText` (`#A1A1AA`)
   - Ukuran Font: `12` (`FontWeight.w500`)

### B. Tombol Berbasis Ikon (Icon Only)
Digunakan pada navigasi cepat dan bar aksi:

1. **Aksi AppBar / Header:**
   - Komponen: `IconButton` (ikon saja, tanpa teks).
   - Wajib menyertakan `tooltip` dalam Bahasa Indonesia (misal: `tooltip: 'Edit Proyek'`, `tooltip: 'Hapus Proyek'`, `tooltip: 'Salin Konteks'`).
   - Warna ikon: `AppColors.primaryText` / `AppColors.secondaryText` / `AppColors.error` (khusus aksi hapus).

2. **Floating Action Button (FAB):**
   - Komponen: `FloatingActionButton` (ikon saja, misal `Icons.add`).
   - Warna Latar: `AppColors.primaryAccent`, Ikon: `AppColors.background`.
   - Wajib menyertakan `tooltip` deskriptif.

---

## 3. Standar Input Field (TextField & Dropdown)

Seluruh input teks (`TextField`, `TextFormField`) dan pilihan (`DropdownButtonFormField`) wajib konsisten dengan spesifikasi berikut:

1. **Sudut Membulat (*Rounded Border*):**
   - Radius seragam: `BorderRadius.circular(10)`.
   - Berlaku pada seluruh status border (`border`, `enabledBorder`, `focusedBorder`, `errorBorder`).

2. **Ukuran & Padding:**
   - Padding internal: `EdgeInsets.symmetric(horizontal: 14, vertical: 12)`.
   - Ukuran font isi input: `12` (`AppColors.primaryText`).

3. **Placeholder / Hint Text Wajib (*TextHint*):**
   - Setiap kolom input **wajib memiliki `hintText`** yang informatif (misal: `"Contoh: Aplikasi Pengingat Jadwal"`, `"Tuliskan nama tahapan...", "https://..."`).
   - Warna hint: `AppColors.secondaryText.withValues(alpha: 0.6)`, ukuran font: `12`.

4. **Warna Permukaan & Garis Batas:**
   - Latar belakang input: `AppColors.surface` (`#1C1C1E`) dengan `filled: true`.
   - Border default: `AppColors.border` (`#343438`).
   - Focused border: `AppColors.primaryAccent` (`#8B9CF6`) dengan ketebalan `1.5`.
   - Error border: `AppColors.error` (`#E98282`).

5. **Dropdown Terbuka Penuh & Truncation (`isExpanded: true`):**
   - Setiap `DropdownButtonFormField` wajib memiliki `isExpanded: true` agar lebar komponen menyesuaikan kontainer dialog/layar dan tidak menyebabkan horizontal overflow saat teks opsi bernilai panjang.
   - Seluruh item teks di dalam `DropdownMenuItem` wajib memiliki `overflow: TextOverflow.ellipsis`.

---

## 4. Standar Bahasa Visual (Human Indo: Singkat, Jelas, dan Tegas)

Seluruh teks visual yang tampak oleh pengguna wajib menggunakan Bahasa Indonesia yang **singkat, jelas, dan tegas** (tanpa kata pengantar bertele-tele, lugas, dan profesional):

1. **Label Status Proyek & Entitas:**
   - Proyek: `active` → **Aktif**, `onHold` → **Tertunda**, `completed` → **Selesai**, `archived` → **Diarsipkan**
   - Ide: **Sudah Terealisasi** vs **Belum Terealisasi**, Relasi: **Ide Bebas**
   - Kendala: **Kendala Teratasi** vs **Kendala Aktif**, Relasi: **Kendala Bebas**
   - Referensi: **Tautan Umum Proyek**

2. **Aksi & Tombol:**
   - "Simpan Proyek", "Simpan Perubahan", "Simpan", "Tambah Tahapan", "Hapus", "Batal", "Salin Konteks", "Buka di Browser", "Salin Tautan".

3. **Pesan Validasi & Konfirmasi:**
   - Validasi: `"Nama proyek tidak boleh kosong"`, `"Judul ide tidak boleh kosong"`, `"Tautan URL web tidak boleh kosong"`.
   - Dialog Hapus: `"Yakin ingin menghapus data ini? Tindakan ini tidak dapat dibatalkan."` (Tegas dan langsung).
   - Feedback SnackBar: `"Konteks proyek berhasil disalin ke clipboard"`, `"Data berhasil disimpan"`.

4. **Empty State:**
   - Judul ramah (font 15): `"Belum ada proyek"`, `"Belum ada tahapan"`, `"Belum ada riwayat aktivitas"`.
   - Deskripsi ringkas (font 12): Memberikan panduan tanpa kata filler (misal: *"Mulai pantau progres dengan membuat proyek pertama Anda."*).

---

## 5. Ringkasan Token Warna (Dark Palette)

| Token | Nilai Hex | Peruntukan |
|---|---|---|
| `background` | `#121212` | Latar belakang layar |
| `surface` | `#1C1C1E` | Latar kartu (*Card*), dialog, input field |
| `surfaceElevated` | `#252528` | Latar elevated element, badge container, snackbar |
| `primaryAccent` | `#8B9CF6` | Tombol utama, focused border, ikon aktif, progress bar |
| `primaryText` | `#F5F5F5` | Teks utama, judul header |
| `secondaryText` | `#A1A1AA` | Teks pendukung, hint text, metadata |
| `border` | `#343438` | Garis pembatas card, divider, border input default |
| `success` | `#81C995` | Status selesai, centang berhasil |
| `warning` | `#E9B96E` | Status kendala, status tertunda |
| `error` | `#E98282` | Status error, tombol hapus, pesan kesalahan |
