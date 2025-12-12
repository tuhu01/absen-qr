# Cara Penggunaan Sistem Absensi QR Code

## 📋 Ringkasan Sistem

Sistem ini menggunakan **QR Code untuk absensi**, bukan login tradisional. Siswa dan guru **TIDAK perlu login** - mereka hanya perlu scan QR code mereka.

---

## 👨‍🎓 Untuk Siswa

### **Siswa TIDAK Perlu Login!**

Siswa tidak memiliki akun login. Mereka hanya perlu:

1. **Buka halaman scan QR:**
   - Akses: `http://172.16.11.102` atau `https://172.16.11.102`
   - Ini adalah halaman utama (tidak perlu login)

2. **Scan QR Code:**
   - Tunjukkan QR code siswa ke kamera
   - Sistem akan otomatis mendeteksi dan mencatat absensi
   - QR code harus sudah di-generate oleh admin terlebih dahulu

3. **Pilih waktu absensi:**
   - **Absen Masuk**: Untuk absensi pagi/masuk
   - **Absen Pulang**: Untuk absensi siang/pulang
   - Bisa diubah dengan tombol di halaman scan

### Cara Mendapatkan QR Code

QR code siswa harus di-generate oleh **admin/petugas**:
1. Admin login ke dashboard
2. Menu: **Generate QR** → **Generate QR Siswa**
3. Pilih kelas → Generate QR untuk semua siswa di kelas tersebut
4. Download QR code dan berikan ke siswa

---

## 👨‍🏫 Untuk Guru

### **Guru TIDAK Perlu Login!**

Guru juga tidak perlu login. Cara absen sama seperti siswa:

1. **Buka halaman scan QR:**
   - Akses: `http://172.16.11.102` atau `https://172.16.11.102`

2. **Scan QR Code:**
   - Tunjukkan QR code guru ke kamera
   - Sistem akan otomatis mendeteksi dan mencatat absensi

3. **Pilih waktu absensi:**
   - **Absen Masuk** atau **Absen Pulang**

### Cara Mendapatkan QR Code

QR code guru harus di-generate oleh **admin/petugas**:
1. Admin login ke dashboard
2. Menu: **Generate QR** → **Generate QR Guru**
3. Generate QR untuk semua guru atau guru tertentu
4. Download QR code dan berikan ke guru

---

## 👨‍💼 Untuk Admin/Petugas

### Login Admin/Petugas

**Hanya admin/petugas yang perlu login** untuk mengelola sistem:

1. **Akses halaman login:**
   - URL: `http://172.16.11.102/admin` atau klik tombol "Dashboard" di halaman scan

2. **Login dengan kredensial:**
   - **Superadmin default:**
     - Email/Username: `superadmin`
     - Password: `superadmin`
   - Atau gunakan akun petugas yang sudah dibuat

3. **Setelah login, bisa:**
   - Lihat dashboard
   - Kelola data siswa
   - Kelola data guru
   - Generate QR code
   - Lihat data absensi
   - Generate laporan
   - Kelola petugas (superadmin only)

---

## 📱 Cara Absen (Siswa & Guru)

### Langkah-langkah:

1. **Buka halaman scan:**
   ```
   http://172.16.11.102
   atau
   https://172.16.11.102
   ```

2. **Pilih kamera:**
   - Di dropdown "Pilih kamera", pilih kamera yang akan digunakan
   - Jika hanya ada 1 kamera, akan otomatis terpilih

3. **Tunjukkan QR Code:**
   - Tunjukkan QR code ke kamera
   - Pastikan QR code terlihat jelas
   - Jangan terlalu jauh atau terlalu dekat

4. **Sistem akan otomatis:**
   - Scan QR code
   - Deteksi apakah siswa atau guru
   - Cek apakah sudah absen hari ini
   - Catat absensi (masuk atau pulang)
   - Tampilkan hasil scan

5. **Hasil:**
   - Jika berhasil: Akan muncul data siswa/guru dan status absensi
   - Jika sudah absen: Akan muncul pesan "Anda sudah absen hari ini"
   - Jika QR code tidak valid: Akan muncul pesan "Data tidak ditemukan"

### Catatan Penting:

- **Siswa/guru TIDAK perlu login** untuk absen
- **QR code harus sudah di-generate** oleh admin
- **Satu QR code = satu siswa/guru**
- **Satu hari hanya bisa absen masuk sekali**
- **Harus absen masuk dulu sebelum bisa absen pulang**

---

## 🔐 Kredensial Default

### Superadmin (Setelah Migration)

- **Email/Username:** `superadmin` atau `adminsuper@gmail.com`
- **Password:** `superadmin`

⚠️ **PENTING:** Ganti password default setelah pertama kali login!

---

## 📊 Fitur Admin Dashboard

Setelah login sebagai admin, bisa:

1. **Dashboard** - Overview data absensi
2. **Data Siswa** - Kelola data siswa (tambah, edit, hapus, import CSV)
3. **Data Guru** - Kelola data guru
4. **Data Absen Siswa** - Lihat dan edit absensi siswa
5. **Data Absen Guru** - Lihat dan edit absensi guru
6. **Generate QR** - Generate QR code untuk siswa/guru
7. **Generate Laporan** - Buat laporan absensi
8. **Kelas & Jurusan** - Kelola kelas dan jurusan
9. **Data Petugas** - Kelola akun petugas (superadmin only)
10. **General Settings** - Pengaturan umum

---

## 🎯 Alur Kerja Lengkap

### Setup Awal (Admin):

1. Login sebagai superadmin
2. Tambah data siswa (manual atau import CSV)
3. Tambah data guru
4. Generate QR code untuk siswa
5. Generate QR code untuk guru
6. Download dan distribusikan QR code

### Penggunaan Harian (Siswa/Guru):

1. Buka halaman scan (tidak perlu login)
2. Scan QR code
3. Sistem otomatis mencatat absensi
4. Selesai!

### Monitoring (Admin):

1. Login ke dashboard
2. Lihat data absensi harian
3. Generate laporan jika diperlukan
4. Edit absensi jika ada kesalahan

---

## ❓ FAQ

### Q: Siswa perlu login tidak?
**A:** Tidak. Siswa tidak perlu login. Hanya scan QR code.

### Q: Bagaimana cara siswa mendapatkan QR code?
**A:** QR code di-generate oleh admin, lalu didistribusikan ke siswa (print/download).

### Q: Bisa absen tanpa QR code?
**A:** Tidak. Harus menggunakan QR code yang sudah di-generate.

### Q: QR code bisa dipakai berulang kali?
**A:** Ya, tapi untuk absensi yang berbeda. Satu hari hanya bisa absen masuk sekali dan pulang sekali.

### Q: Bagaimana jika QR code hilang?
**A:** Admin bisa generate ulang QR code untuk siswa/guru tersebut.

---

## 📝 Catatan

- Sistem ini **tidak menggunakan login untuk siswa/guru**
- Semua absensi dilakukan melalui **scan QR code**
- **Hanya admin/petugas** yang perlu login untuk mengelola sistem
- QR code harus di-generate terlebih dahulu oleh admin

