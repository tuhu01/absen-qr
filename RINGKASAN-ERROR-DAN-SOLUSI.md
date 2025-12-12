# Ringkasan Error dan Solusi Setup

## Error yang Ditemukan dan Sudah Diperbaiki

### 1. ❌ Error: Halaman Default Apache2
**Lokasi:** Apache2 masih berjalan di port 80

**Gejala:**
- Masih melihat halaman "Apache2 Default Page"
- Nginx tidak bisa start karena port 80 sudah digunakan

**Solusi:**
- Stop Apache2: `sudo systemctl stop apache2`
- Disable Apache2: `sudo systemctl disable apache2`
- Start Nginx: `sudo systemctl start nginx`

**File:** `switch-to-nginx.sh`

---

### 2. ❌ Error: 404 Not Found
**Lokasi:** Konfigurasi nginx belum benar atau file tidak ditemukan

**Gejala:**
- Browser menampilkan "404 Not Found"
- Nginx error log: file tidak ditemukan

**Solusi:**
- Update konfigurasi nginx dengan versi PHP yang benar
- Pastikan document root mengarah ke `/home/tuhu-pangestu/college/absen-qr/public`
- Enable site nginx

**File:** `fix-404-complete.sh`, `apply-nginx-config.sh`

---

### 3. ❌ Error: Permission Denied (13)
**Lokasi:** `/home/tuhu-pangestu/college/absen-qr/public/`

**Gejala:**
- Nginx error log: `stat() failed (13: Permission denied)`
- www-data tidak bisa akses folder aplikasi

**Penyebab:**
- Folder `/home/tuhu-pangestu` memiliki permission `750` (drwxr-x---)
- www-data tidak bisa traverse ke folder aplikasi

**Solusi:**
```bash
sudo chmod 755 /home/tuhu-pangestu
sudo chmod 755 /home/tuhu-pangestu/college
sudo chmod 755 /home/tuhu-pangestu/college/absen-qr
sudo chown -R www-data:www-data /home/tuhu-pangestu/college/absen-qr/public
```

**File:** `fix-permission-complete.sh`

---

### 4. ❌ Error: ERR_TOO_MANY_REDIRECTS
**Lokasi:** `app/Config/Filters.php`

**Gejala:**
- Browser menampilkan "ERR_TOO_MANY_REDIRECTS"
- Redirect loop terjadi

**Penyebab:**
1. **Filter `forcehttps` aktif** (line 61)
   - Memaksa semua request ke HTTPS
   - Aplikasi berjalan di HTTP, menyebabkan loop

2. **Filter `login` aktif secara global** (line 83)
   - Semua request yang tidak login di-redirect ke login
   - Halaman login juga di-redirect, menyebabkan loop

**Solusi:**
1. Nonaktifkan `forcehttps` dari `required` filters:
   ```php
   // 'forcehttps', // DISABLED untuk HTTP
   ```

2. Nonaktifkan `login` dari `globals`:
   ```php
   // 'login' // DISABLED - hanya untuk route tertentu
   ```
   Login filter tetap aktif untuk route tertentu (admin/*, register/) di `filters` array

**File yang diubah:**
- `app/Config/Filters.php` (line 61 dan 83)

**File script:** `fix-redirect-loop.sh`, `fix-login-filter.sh`

---

## Ringkasan File Konfigurasi yang Diubah

### 1. `app/Config/Filters.php`
- **Line 61:** Comment `'forcehttps'` di `required` array
- **Line 83:** Comment `'login'` di `globals` array

### 2. `app/Config/App.php`
- **Line 24:** Update `baseURL` ke `http://172.16.11.102/`

### 3. `.env`
- Update `app.baseURL` ke `http://172.16.11.102/`

### 4. `nginx.conf`
- Update `server_name` ke `_` (menerima dari IP manapun)
- Update `fastcgi_pass` dengan versi PHP yang benar

---

## Script yang Dibuat untuk Fix

1. **`switch-to-nginx.sh`** - Switch dari Apache2 ke Nginx
2. **`fix-404-complete.sh`** - Fix error 404 lengkap
3. **`fix-permission-complete.sh`** - Fix permission denied
4. **`fix-redirect-loop.sh`** - Fix redirect loop
5. **`fix-login-filter.sh`** - Fix login filter
6. **`apply-nginx-config.sh`** - Apply konfigurasi nginx
7. **`debug-nginx.sh`** - Debugging nginx

---

## Status Akhir

✅ **Semua error sudah diperbaiki:**
- ✅ Apache2 sudah dihentikan, Nginx berjalan
- ✅ Permission folder sudah benar
- ✅ Konfigurasi nginx sudah benar
- ✅ Filter redirect loop sudah dinonaktifkan
- ✅ Aplikasi bisa diakses di http://172.16.11.102

---

## Tips Troubleshooting

Jika masih ada masalah, cek:
1. **Log nginx:** `sudo tail -f /var/log/nginx/absen-qr-error.log`
2. **Status nginx:** `sudo systemctl status nginx`
3. **Status PHP-FPM:** `sudo systemctl status php8.3-fpm`
4. **Test dari server:** `curl http://localhost`
5. **Clear cache browser** (Ctrl+Shift+Delete)

