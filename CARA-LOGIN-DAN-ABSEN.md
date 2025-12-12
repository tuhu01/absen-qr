# Cara Login Admin dan Cara Siswa Absen

## 🔐 CARA LOGIN ADMIN

### URL Login:
```
http://172.16.11.102/login
atau
http://172.16.11.102/admin
```

**Kredensial Default:**
- **Username/Email:** `superadmin` atau `adminsuper@gmail.com`
- **Password:** `superadmin`

### Jika `/admin` Tidak Redirect ke Login:

Jika mengakses `/admin` malah menampilkan halaman scan QR, coba:

1. **Akses langsung halaman login:**
   ```
   http://172.16.11.102/login
   ```

2. **Clear browser cookies:**
   - Tekan Ctrl+Shift+Delete
   - Pilih "Cookies and other site data"
   - Clear data
   - Akses lagi `/admin`

3. **Setelah login:**
   - Akan masuk ke Dashboard Admin
   - Bisa mengelola semua data

---

## 👨‍🎓 CARA SISWA ABSEN

### **Siswa TIDAK Perlu Login!**

Siswa **TIDAK memiliki akun login**. Mereka hanya perlu scan QR code.

### Langkah-langkah:

1. **Buka halaman scan:**
   ```
   http://172.16.11.102
   ```
   (Ini adalah halaman utama, tidak perlu login)

2. **Scan QR Code:**
   - Tunjukkan QR code siswa ke kamera
   - Pastikan QR code terlihat jelas
   - Sistem akan otomatis mendeteksi dan mencatat absensi

3. **Pilih waktu:**
   - **Absen Masuk**: Untuk absensi pagi
   - **Absen Pulang**: Untuk absensi siang
   - Bisa diubah dengan tombol di halaman

4. **Hasil:**
   - Jika berhasil: Muncul data siswa dan status absensi
   - Jika sudah absen: Muncul pesan "Anda sudah absen hari ini"
   - Jika QR tidak valid: Muncul pesan "Data tidak ditemukan"

---

## 📱 QR CODE DARIMANA?

### **QR Code HARUS di-generate oleh Admin!**

Siswa/guru **TIDAK bisa membuat QR code sendiri**. QR code harus di-generate oleh admin terlebih dahulu.

### Cara Generate QR Code (Admin):

1. **Login sebagai admin:**
   - URL: `http://172.16.11.102/login`
   - Username: `superadmin`
   - Password: `superadmin`

2. **Generate QR Code Siswa:**
   - Menu: **Generate QR** (di sidebar)
   - Pilih tab **"Generate QR Siswa"**
   - Pilih **Kelas** dari dropdown
   - Klik **"Generate"** untuk semua siswa di kelas tersebut
   - Atau generate per siswa
   - **Download** QR code (bisa download semua atau per siswa)

3. **Generate QR Code Guru:**
   - Menu: **Generate QR**
   - Pilih tab **"Generate QR Guru"**
   - Klik **"Generate"** untuk semua guru
   - Atau generate per guru
   - **Download** QR code

4. **Distribusikan QR Code:**
   - Print QR code yang sudah di-download
   - Berikan ke siswa/guru
   - QR code bisa di-print di kertas atau di-simpan di HP

### Catatan Penting:

- ✅ **QR code harus di-generate dulu** sebelum siswa bisa absen
- ✅ **Satu QR code = satu siswa/guru**
- ✅ **QR code bisa digunakan berulang kali** (untuk absensi berbeda)
- ✅ **QR code tidak bisa dibuat sendiri oleh siswa**

---

## 📋 ALUR LENGKAP

### Setup Awal (Admin):

1. Login sebagai superadmin
2. Tambah data siswa (Menu: Data Siswa → Tambah Siswa)
3. Tambah data guru (Menu: Data Guru → Tambah Guru)
4. Generate QR code untuk siswa (Menu: Generate QR → Generate QR Siswa)
5. Generate QR code untuk guru (Menu: Generate QR → Generate QR Guru)
6. Download dan print QR code
7. Distribusikan QR code ke siswa/guru

### Penggunaan Harian (Siswa):

1. Buka `http://172.16.11.102` (tidak perlu login)
2. Scan QR code mereka
3. Sistem otomatis mencatat absensi
4. Selesai!

---

## ❓ FAQ

### Q: Siswa perlu login tidak?
**A:** Tidak. Siswa tidak perlu login. Hanya scan QR code.

### Q: QR code darimana?
**A:** QR code di-generate oleh admin di menu "Generate QR", lalu didistribusikan ke siswa.

### Q: Bisa absen tanpa QR code?
**A:** Tidak. Harus menggunakan QR code yang sudah di-generate oleh admin.

### Q: Bagaimana jika QR code hilang?
**A:** Admin bisa generate ulang QR code untuk siswa/guru tersebut di menu Generate QR.

### Q: Mengapa `/admin` menampilkan halaman scan?
**A:** 
- Mungkin sudah login sebelumnya (cek session)
- Atau filter login tidak bekerja
- **Solusi:** Akses langsung `/login` atau clear cookies

---

## 🎯 URL Penting

- **Halaman Scan (Siswa/Guru):** `http://172.16.11.102`
- **Login Admin:** `http://172.16.11.102/login`
- **Dashboard Admin:** `http://172.16.11.102/admin` (setelah login)

---

## 📝 Ringkasan

1. **Siswa/Guru:** TIDAK perlu login, hanya scan QR code
2. **Admin:** Perlu login di `/login`
3. **QR Code:** Harus di-generate oleh admin terlebih dahulu
4. **Absen:** Buka halaman scan → Scan QR → Selesai!

