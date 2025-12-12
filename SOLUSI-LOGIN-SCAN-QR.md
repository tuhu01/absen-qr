# Solusi: Route /login Menampilkan Halaman Scan QR

## Masalah
Route `/login` masih menampilkan halaman scan QR (bukan form login), dan muncul alert "cannot access camera".

## Penyebab
1. **Route `/login` tidak match dengan benar** - masih diarahkan ke `Scan::index` bukan `AuthController::login`
2. **Route priority tidak bekerja** - route `/` masih menangkap semua request termasuk `/login`
3. **PHP-FPM cache** masih menggunakan route lama

## Solusi

### 1. Pastikan Route Login Benar
File: `app/Config/Routes.php`

Route login **HARUS** sebelum route `/`:
```php
// Auth Routes (Login/Logout) - HARUS SEBELUM ROUTE LAINNYA
$routes->get('login', '\Myth\Auth\Controllers\AuthController::login', ['as' => 'login', 'priority' => 1]);
$routes->post('login', '\Myth\Auth\Controllers\AuthController::attemptLogin', ['priority' => 1]);
$routes->get('logout', '\Myth\Auth\Controllers\AuthController::logout', ['as' => 'logout', 'priority' => 1]);

// Scan - HARUS SETELAH route login
$routes->get('/', 'Scan::index');
```

### 2. Enable Route Priority
File: `app/Config/Routing.php`

```php
public bool $prioritize = true;  // Harus true
```

### 3. Restart Services (WAJIB!)
```bash
sudo systemctl restart php8.3-fpm nginx
```

### 4. Clear Cache
```bash
cd /home/tuhu-pangestu/college/absen-qr
rm -rf writable/cache/*
```

### 5. Test Route
```bash
php spark routes | grep login
```

Seharusnya muncul:
```
GET    /login    \Myth\Auth\Controllers\AuthController::login
POST   /login    \Myth\Auth\Controllers\AuthController::attemptLogin
GET    /logout   \Myth\Auth\Controllers\AuthController::logout
```

### 6. Test Akses
```bash
curl -s http://192.168.137.159/login | grep -i "login petugas"
```

Seharusnya muncul teks "Login petugas", bukan "Absen Masuk".

## Troubleshooting

### Jika masih menampilkan halaman scan QR:
1. **Cek apakah route terdaftar:**
   ```bash
   php spark routes | grep login
   ```

2. **Cek log error:**
   ```bash
   tail -50 writable/logs/*.php
   ```

3. **Test dengan index.php:**
   ```bash
   curl http://192.168.137.159/index.php/login
   ```
   Jika ini bekerja, berarti masalahnya di Nginx rewrite rules.

4. **Pastikan route login SEBELUM route `/`:**
   - Buka `app/Config/Routes.php`
   - Pastikan route login ada di baris sebelum `$routes->get('/', 'Scan::index');`

5. **Pastikan `prioritize = true` di Routing.php:**
   - Buka `app/Config/Routing.php`
   - Pastikan `public bool $prioritize = true;`

6. **Restart services lagi:**
   ```bash
   sudo systemctl restart php8.3-fpm nginx
   ```

## Catatan Penting

- Route login **HARUS** sebelum route `/` (root)
- Route priority **HARUS** diaktifkan (`prioritize = true`)
- PHP-FPM dan Nginx **HARUS** di-restart setelah perubahan route
- Cache **HARUS** di-clear setelah perubahan route
