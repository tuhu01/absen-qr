# Solusi Route Login Tidak Bekerja

## Masalah
Route `/login` masih menampilkan halaman scan QR, bukan form login.

## Yang Sudah Dilakukan

1. ✅ Route login sudah ditambahkan di `app/Config/Routes.php`
2. ✅ `set404Override()` sudah dinonaktifkan
3. ✅ Cache sudah di-clear
4. ✅ Route login menggunakan namespace lengkap

## Solusi Final

### 1. Restart PHP-FPM dan Nginx

**PENTING:** Route tidak akan bekerja sampai PHP-FPM dan Nginx di-restart!

```bash
sudo systemctl restart php8.1-fpm  # atau php8.2-fpm
sudo systemctl restart nginx
```

Atau jalankan script:
```bash
sudo bash RESTART-SERVICES.sh
```

### 2. Clear Browser Cache

- Tekan `Ctrl+Shift+Delete`
- Pilih "Cached images and files"
- Clear data
- Atau gunakan mode incognito

### 3. Test Akses

Buka: `http://172.16.11.102/login`

Seharusnya menampilkan:
- Title: "Login petugas"
- Form dengan field username/email dan password
- Bukan halaman scan QR

### 4. Jika Masih Tidak Bekerja

Cek log error:
```bash
tail -50 writable/logs/*.php
sudo tail -50 /var/log/nginx/error.log
```

Cek apakah route terdaftar:
```bash
php spark routes | grep login
```

## Route Login di Routes.php

Route login harus ada di **BARIS PERTAMA** setelah komentar, sebelum route lain:

```php
// Auth Routes (Login/Logout) - HARUS SEBELUM ROUTE LAINNYA
$routes->get('login', '\Myth\Auth\Controllers\AuthController::login', ['as' => 'login']);
$routes->post('login', '\Myth\Auth\Controllers\AuthController::attemptLogin');
$routes->get('logout', '\Myth\Auth\Controllers\AuthController::logout', ['as' => 'logout']);
```

## Catatan Penting

- Route login **HARUS** sebelum route `/` (root)
- Route login **HARUS** menggunakan namespace lengkap: `\Myth\Auth\Controllers\AuthController`
- `set404Override()` harus dinonaktifkan atau di-set dengan benar
- PHP-FPM dan Nginx **HARUS** di-restart setelah mengubah Routes.php

