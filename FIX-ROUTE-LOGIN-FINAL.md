# Fix Route Login - Masih Menampilkan Halaman Scan QR

## Masalah
Route `/login` masih menampilkan halaman scan QR ("Absen Masuk"), bukan form login.

## Penyebab
Route `/login` tidak match dengan benar karena:
1. Route priority tidak bekerja dengan benar
2. Route `/` masih menangkap semua request termasuk `/login`
3. PHP-FPM cache masih menggunakan route lama

## Solusi yang Sudah Diterapkan

### 1. Update Route dengan Priority Tinggi
File: `app/Config/Routes.php`

```php
// Auth Routes (Login/Logout) - HARUS SEBELUM ROUTE LAINNYA
$routes->get('login', '\Myth\Auth\Controllers\AuthController::login', ['as' => 'login', 'priority' => 100]);
$routes->post('login', '\Myth\Auth\Controllers\AuthController::attemptLogin', ['priority' => 100]);
$routes->get('logout', '\Myth\Auth\Controllers\AuthController::logout', ['as' => 'logout', 'priority' => 100]);

// Scan - HARUS SETELAH route login dengan priority rendah
$routes->get('/', 'Scan::index', ['priority' => 1]);
```

### 2. Enable Route Priority
File: `app/Config/Routing.php`

```php
public bool $prioritize = true;  // Harus true
```

## Langkah yang HARUS Dilakukan

### 1. Restart PHP-FPM dan Nginx (WAJIB!)
```bash
sudo systemctl restart php8.3-fpm nginx
```

### 2. Clear Cache
```bash
cd /home/tuhu-pangestu/college/absen-qr
rm -rf writable/cache/*
```

### 3. Clear Browser Cache
- Tekan `Ctrl+Shift+Delete`
- Pilih "Cached images and files"
- Clear data
- Atau gunakan mode incognito

### 4. Test Route
```bash
php spark routes | grep login
```

Seharusnya muncul:
```
GET    /login    \Myth\Auth\Controllers\AuthController::login
POST   /login    \Myth\Auth\Controllers\AuthController::attemptLogin
GET    /logout   \Myth\Auth\Controllers\AuthController::logout
```

### 5. Test Akses
```bash
curl -s http://192.168.137.159/login | grep -i "login petugas"
```

Seharusnya muncul teks "Login petugas", bukan "Absen Masuk".

## Troubleshooting

### Jika masih menampilkan "Absen Masuk":
1. **Pastikan route login SEBELUM route `/`:**
   - Buka `app/Config/Routes.php`
   - Pastikan route login ada di baris sebelum `$routes->get('/', 'Scan::index');`

2. **Pastikan `prioritize = true` di Routing.php:**
   - Buka `app/Config/Routing.php`
   - Pastikan `public bool $prioritize = true;`

3. **Cek apakah route terdaftar:**
   ```bash
   php spark routes | grep login
   ```

4. **Restart services lagi:**
   ```bash
   sudo systemctl restart php8.3-fpm nginx
   ```

5. **Cek log error:**
   ```bash
   tail -50 writable/logs/*.php
   sudo tail -50 /var/log/nginx/error.log
   ```

6. **Test dengan index.php:**
   ```bash
   curl http://192.168.137.159/index.php/login
   ```
   Jika ini bekerja, berarti masalahnya di Nginx rewrite rules.

## Catatan Penting

- Route login **HARUS** sebelum route `/` (root)
- Route login **HARUS** memiliki priority lebih tinggi (100 vs 1)
- Route priority **HARUS** diaktifkan (`prioritize = true`)
- PHP-FPM dan Nginx **HARUS** di-restart setelah perubahan route
- Cache **HARUS** di-clear setelah perubahan route
