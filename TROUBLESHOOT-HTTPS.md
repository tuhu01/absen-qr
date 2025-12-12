# Troubleshooting: CSS & Kamera Tidak Bekerja Setelah Setup HTTPS

## Masalah

Setelah menjalankan `setup-https.sh`:
- CSS tidak ter-load (tampilan tanpa style)
- Kamera tidak bisa diakses

## Penyebab

1. **Browser memblokir karena self-signed certificate**
   - Browser menampilkan warning "Your connection is not private"
   - User belum accept certificate
   - Browser memblokir semua resources sampai certificate di-accept

2. **Browser cache masih menyimpan HTTP version**
   - Cache lama masih menggunakan HTTP
   - Perlu clear cache

3. **Mixed content**
   - Beberapa resource masih menggunakan HTTP
   - Browser memblokir mixed content

## Solusi

### Langkah 1: Fix Konfigurasi

Jalankan script untuk verifikasi dan fix:

```bash
sudo bash fix-https-issues.sh
```

### Langkah 2: Accept Certificate di Browser

**PENTING:** Ini langkah yang paling penting!

1. **Akses:** `https://172.16.11.102`

2. **Browser akan menampilkan warning:**
   ```
   Your connection is not private
   NET::ERR_CERT_AUTHORITY_INVALID
   ```

3. **Klik "Advanced"** atau "Lanjutkan"

4. **Klik "Proceed to 172.16.11.102 (unsafe)"** atau "Continue to site"

5. **Setelah accept certificate:**
   - CSS seharusnya sudah muncul
   - Browser akan minta permission kamera

### Langkah 3: Berikan Permission Kamera

1. **Browser akan menampilkan popup:**
   ```
   https://172.16.11.102 wants to use your camera
   ```

2. **Klik "Allow"** atau "Izinkan"

3. **Kamera seharusnya sudah bisa digunakan**

### Langkah 4: Clear Cache (Jika Masih Bermasalah)

1. **Clear cache browser:**
   - Chrome: Ctrl+Shift+Delete
   - Pilih "Cached images and files"
   - Time range: "All time"
   - Clear data

2. **Hard reload:**
   - Ctrl+F5 atau Shift+F5

3. **Reload halaman**

## Verifikasi

### Cek CSS

1. **Buka Developer Tools:** F12
2. **Tab Network:**
   - Reload page (F5)
   - Cari file CSS (material-dashboard.css)
   - Status harus "200" (bukan 404 atau blocked)

### Cek Kamera

1. **Buka Console:** F12 → Console
2. **Cari error:**
   - Jika ada "getUserMedia is not defined" → Certificate belum di-accept
   - Jika ada "Permission denied" → Permission kamera belum diberikan

## Troubleshooting Detail

### CSS Masih Tidak Muncul

1. **Cek baseURL di source:**
   - View page source (Ctrl+U)
   - Cari link CSS
   - Pastikan URL dimulai dengan `https://`

2. **Cek Network tab:**
   - F12 → Network
   - Filter: CSS
   - Lihat status code
   - Jika 404: baseURL salah
   - Jika blocked: certificate belum di-accept

3. **Cek console:**
   - F12 → Console
   - Cari error "Mixed Content" atau "Blocked"

### Kamera Masih Tidak Bisa

1. **Cek permission kamera:**
   - Chrome: `chrome://settings/content/camera`
   - Pastikan site tidak di-block

2. **Cek console:**
   - F12 → Console
   - Cari error terkait `getUserMedia`

3. **Test di browser lain:**
   - Coba di Firefox atau Edge
   - Untuk memastikan bukan masalah browser spesifik

## Catatan Penting

- **Self-signed certificate hanya untuk development**
- Browser akan selalu menampilkan warning untuk self-signed certificate
- Ini NORMAL dan AMAN untuk development
- Untuk production, gunakan certificate dari CA terpercaya (Let's Encrypt)

## Alternatif: Gunakan HTTP untuk Development

Jika tidak ingin deal dengan certificate warning:

1. **Nonaktifkan HTTPS:**
   ```bash
   sudo rm /etc/nginx/sites-enabled/absen-qr-https
   sudo ln -s /etc/nginx/sites-available/absen-qr /etc/nginx/sites-enabled/
   sudo systemctl reload nginx
   ```

2. **Update baseURL ke HTTP:**
   ```bash
   bash fix-baseurl.sh
   ```

3. **Kamera tidak akan bisa diakses** (kecuali via localhost)

