# Fix Login Route

## Masalah
Route `/login` menampilkan halaman scan QR, bukan halaman login.

## Solusi
Route login sudah ditambahkan di `app/Config/Routes.php`:

```php
// Auth Routes (Login/Logout) - HARUS SEBELUM ROUTE LAINNYA
$routes->get('login', '\Myth\Auth\Controllers\AuthController::login', ['as' => 'login']);
$routes->post('login', '\Myth\Auth\Controllers\AuthController::attemptLogin');
$routes->get('logout', '\Myth\Auth\Controllers\AuthController::logout', ['as' => 'logout']);
```

## Langkah Troubleshooting

1. **Clear cache:**
   ```bash
   rm -rf writable/cache/*
   ```

2. **Restart PHP-FPM:**
   ```bash
   sudo systemctl restart php8.1-fpm
   # atau
   sudo systemctl restart php8.2-fpm
   ```

3. **Restart Nginx:**
   ```bash
   sudo systemctl restart nginx
   ```

4. **Test akses:**
   - Buka: `http://172.16.11.102/login`
   - Seharusnya menampilkan form login, bukan halaman scan

5. **Jika masih tidak bekerja:**
   - Cek log: `writable/logs/`
   - Cek error Nginx: `sudo tail -f /var/log/nginx/error.log`
   - Cek PHP-FPM: `sudo tail -f /var/log/php8.1-fpm.log`

## Catatan
Route login harus diletakkan **SEBELUM** route scan (`/`) agar tidak di-override.

