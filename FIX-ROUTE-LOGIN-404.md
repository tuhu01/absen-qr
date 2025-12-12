# Fix Route Login 404 Error

## Masalah
Route `/login` mengembalikan **404 Not Found** atau menampilkan halaman scan QR, bukan form login.

## Penyebab
1. Route `/login` tidak match dengan benar
2. Route `/` (root) menangkap semua request termasuk `/login`
3. Route priority tidak bekerja karena `prioritize` masih `false` di `Routing.php`
4. PHP-FPM cache masih menggunakan route lama

## Solusi yang Sudah Diterapkan

### 1. Enable Route Priority
File: `app/Config/Routing.php`
```php
public bool $prioritize = true;  // Diubah dari false ke true
```

### 2. Update Route Login
File: `app/Config/Routes.php`
```php
// Auth Routes (Login/Logout) - HARUS SEBELUM ROUTE LAINNYA
$routes->match(['get', 'post'], 'login', '\Myth\Auth\Controllers\AuthController::login', ['as' => 'login', 'priority' => 1]);
$routes->post('login', '\Myth\Auth\Controllers\AuthController::attemptLogin', ['priority' => 1]);
$routes->get('logout', '\Myth\Auth\Controllers\AuthController::logout', ['as' => 'logout', 'priority' => 1]);
```

## Langkah yang HARUS Dilakukan

### 1. Fix Cache Permission (WAJIB!)
```bash
cd /home/tuhu-pangestu/college/absen-qr
sudo chown -R www-data:www-data writable
sudo chmod -R 775 writable/cache writable/logs writable/session
rm -rf writable/cache/*
```

### 2. Restart PHP-FPM dan Nginx (WAJIB!)
```bash
sudo systemctl restart php8.3-fpm
sudo systemctl restart nginx
```

### 3. Clear Browser Cache
- Tekan `Ctrl+Shift+Delete`
- Pilih "Cached images and files"
- Clear data
- Atau gunakan mode incognito

### 4. Test Route
```bash
cd /home/tuhu-pangestu/college/absen-qr
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
curl -I http://192.168.137.159/login
```

Seharusnya mengembalikan **200 OK**, bukan 404.

## Troubleshooting

### Jika masih 404:
1. **Cek log error:**
   ```bash
   tail -50 writable/logs/*.php
   sudo tail -50 /var/log/nginx/error.log
   ```

2. **Pastikan route terdaftar:**
   ```bash
   php spark routes | grep login
   ```

3. **Test dengan index.php:**
   ```bash
   curl http://192.168.137.159/index.php/login
   ```
   Jika ini bekerja, berarti masalahnya di Nginx rewrite rules.

4. **Cek nginx configuration:**
   ```bash
   sudo nginx -t
   cat /etc/nginx/sites-enabled/* | grep -A 5 "location /"
   ```

### Jika masih menampilkan halaman scan QR:
- Route `/` masih menangkap request `/login`
- Pastikan route login **SEBELUM** route `/` di Routes.php
- Pastikan `prioritize = true` di Routing.php
- Restart PHP-FPM dan Nginx

## Catatan Penting

1. **Route login HARUS sebelum route `/`** (root)
2. **Priority route login harus lebih tinggi** (priority => 1)
3. **`prioritize` harus `true`** di `Routing.php`
4. **PHP-FPM dan Nginx HARUS di-restart** setelah perubahan
5. **Cache HARUS di-clear** setelah perubahan route
6. **Permission cache HARUS benar** (775 untuk www-data)
