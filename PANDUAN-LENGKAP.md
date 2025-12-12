# Panduan Lengkap Sistem Absensi QR Code

## 🎯 Konsep Sistem

Sistem ini menggunakan **QR Code untuk absensi**, bukan login tradisional untuk siswa/guru.

### Prinsip Dasar:
- ✅ **Siswa/Guru**: TIDAK perlu login, hanya scan QR code
- ✅ **Admin/Petugas**: Perlu login untuk mengelola sistem
- ✅ **QR Code**: Harus di-generate oleh admin terlebih dahulu

---

## 👨‍🎓 CARA SISWA ABSEN

### **Siswa TIDAK Perlu Login!**

1. **Buka halaman scan:**
   ```
   http://172.16.11.102
   atau
   https://172.16.11.102
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

### **QR Code Siswa Darimana?**

QR code siswa **HARUS di-generate oleh admin** terlebih dahulu:

1. **Admin login** ke dashboard (`/admin`)
2. Menu: **Generate QR** → **Generate QR Siswa**
3. Pilih kelas
4. Klik "Generate" untuk semua siswa di kelas tersebut
5. Download QR code (bisa download per siswa atau semua sekaligus)
6. Print dan berikan ke siswa

**Tanpa QR code, siswa TIDAK bisa absen!**

---

## 👨‍🏫 CARA GURU ABSEN

### **Guru TIDAK Perlu Login!**

Cara absen guru sama seperti siswa:

1. Buka halaman scan: `http://172.16.11.102`
2. Scan QR code guru
3. Pilih waktu (masuk/pulang)
4. Selesai!

### **QR Code Guru Darimana?**

QR code guru juga **HARUS di-generate oleh admin**:

1. Admin login ke dashboard
2. Menu: **Generate QR** → **Generate QR Guru**
3. Generate QR untuk semua guru atau guru tertentu
4. Download dan berikan ke guru

---

## 👨‍💼 CARA LOGIN ADMIN

### **Hanya Admin yang Perlu Login**

1. **Akses halaman login:**
   ```
   http://172.16.11.102/admin
   atau
   https://172.16.11.102/admin
   ```

2. **Kredensial default:**
   - **Username/Email:** `superadmin` atau `adminsuper@gmail.com`
   - **Password:** `superadmin`

3. **Setelah login:**
   - Akan masuk ke Dashboard
   - Bisa mengelola semua data
   - Bisa generate QR code

⚠️ **PENTING:** Ganti password default setelah pertama kali login!

---

## 📋 ALUR KERJA LENGKAP

### Setup Awal (Admin):

1. **Login sebagai superadmin:**
   - URL: `/admin`
   - Username: `superadmin`
   - Password: `superadmin`

2. **Tambah data siswa:**
   - Menu: **Data Siswa** → **Tambah Siswa**
   - Atau **Import CSV** untuk banyak siswa sekaligus

3. **Tambah data guru:**
   - Menu: **Data Guru** → **Tambah Guru**

4. **Generate QR Code:**
   - Menu: **Generate QR** → **Generate QR Siswa**
   - Pilih kelas → Generate → Download
   - Menu: **Generate QR** → **Generate QR Guru**
   - Generate → Download

5. **Distribusikan QR Code:**
   - Print QR code
   - Berikan ke siswa/guru

### Penggunaan Harian (Siswa/Guru):

1. **Buka halaman scan:**
   - `http://172.16.11.102` (tidak perlu login)

2. **Scan QR code:**
   - Tunjukkan QR code ke kamera
   - Sistem otomatis mencatat absensi

3. **Selesai!**

### Monitoring (Admin):

1. **Login ke dashboard:**
   - URL: `/admin`

2. **Lihat data absensi:**
   - Menu: **Data Absen Siswa** atau **Data Absen Guru**
   - Pilih tanggal dan kelas (untuk siswa)

3. **Generate laporan:**
   - Menu: **Generate Laporan**
   - Pilih periode dan jenis laporan

---

## 🔍 TROUBLESHOOTING

### Q: Mengapa `/admin` menampilkan halaman scan?

**A:** Kemungkinan:
1. Filter login tidak bekerja dengan benar
2. Sudah login sebelumnya (cek session)
3. Routing bermasalah

**Solusi:**
- Clear browser cache dan cookies
- Coba akses langsung: `http://172.16.11.102/admin/login`
- Atau logout dulu jika sudah login

### Q: Siswa tidak punya QR code, bagaimana?

**A:** QR code harus di-generate oleh admin:
1. Admin login
2. Generate QR untuk siswa tersebut
3. Download dan berikan ke siswa

### Q: QR code tidak terdeteksi?

**A:** 
- Pastikan QR code jelas dan tidak rusak
- Pastikan pencahayaan cukup
- Pastikan kamera bisa diakses (perlu HTTPS atau localhost)

### Q: "Data tidak ditemukan" saat scan?

**A:**
- QR code tidak valid atau belum di-generate
- Data siswa/guru tidak ada di database
- QR code rusak atau tidak jelas

---

## 📝 CATATAN PENTING

1. **Siswa/Guru TIDAK perlu login** - hanya scan QR
2. **QR code HARUS di-generate admin** terlebih dahulu
3. **Satu QR code = satu siswa/guru**
4. **Satu hari hanya bisa absen masuk sekali**
5. **Harus absen masuk dulu sebelum absen pulang**
6. **Hanya admin yang perlu login** untuk mengelola sistem

---

## 🎯 URL Penting

- **Halaman Scan (Siswa/Guru):** `http://172.16.11.102`
- **Login Admin:** `http://172.16.11.102/admin`
- **Dashboard Admin:** `http://172.16.11.102/admin/dashboard`

---

## 📞 Bantuan

Jika ada masalah:
1. Cek dokumentasi di folder project
2. Cek log: `writable/logs/`
3. Pastikan database sudah di-migrate
4. Pastikan QR code sudah di-generate

