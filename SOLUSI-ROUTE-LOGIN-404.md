# Solusi Route Login 404 Not Found

## Masalah
Route `/login` mengembalikan **404 Not Found** ketika diakses via IP `http://192.168.137.159/login`, padahal di localhost bisa akses ke login.

## Penyebab
1. **PHP-FPM cache** masih menggunakan route lama
2. **Route tidak terdaftar** dengan benar karena cache permission error
3. **Services belum di-restart** setelah perubahan route

## Solusi

### 1. Fix Permission Cache (WAJIB!)
```bash
cd /home/tuhu-pangestu/college/absen-qr
sudo chmod -R 775 writable/cache writable/logs writable/session
sudo chown -R www-data:www-data writable
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

## Konfigurasi Route yang Benar

File: `app/Config/Routes.php`

```php
// Auth Routes (Login/Logout) - HARUS SEBELUM ROUTE LAINNYA
// Route login langsung menggunakan Myth\Auth controller dengan priority tinggi
$routes->get('login', '\Myth\Auth\Controllers\AuthController::login', ['as' => 'login', 'priority' => 1]);
$routes->post('login', '\Myth\Auth\Controllers\AuthController::attemptLogin', ['priority' => 1]);
$routes->get('logout', '\Myth\Auth\Controllers\AuthController::logout', ['as' => 'logout', 'priority' => 1]);

// Scan
$routes->get('/', 'Scan::index');
```

## Catatan Penting

1. **Route login HARUS sebelum route `/`** (root)
2. **Priority route login harus lebih tinggi** (priority => 1)
3. **PHP-FPM dan Nginx HARUS di-restart** setelah mengubah Routes.php
4. **Cache HARUS di-clear** setelah perubahan route
5. **Permission cache HARUS benar** (775 untuk www-data)

## Troubleshooting

### Jika masih 404:
1. Cek log error: `tail -50 writable/logs/*.php`
2. Cek nginx error log: `sudo tail -50 /var/log/nginx/error.log`
3. Pastikan route terdaftar: `php spark routes | grep login`
4. Test dengan index.php: `curl http://192.168.137.159/index.php/login`

### Jika route terdaftar tapi masih 404:
- Cek nginx configuration: `sudo nginx -t`
- Pastikan `try_files` di nginx.conf benar
- Restart nginx: `sudo systemctl restart nginx`
