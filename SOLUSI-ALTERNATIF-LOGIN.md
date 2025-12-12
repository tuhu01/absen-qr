# Solusi Alternatif Route Login

## Masalah
Route `/login` masih 404 Not Found meskipun sudah ditambahkan di Routes.php.

## Solusi Alternatif

### Opsi 1: Akses via index.php
Coba akses dengan `index.php`:
```
http://172.16.11.102/index.php/login
```

Jika ini bekerja, berarti masalahnya di konfigurasi Nginx rewrite rules.

### Opsi 2: Gunakan Route /admin/login
Jika route `/admin` bekerja, coba tambahkan route login di dalam group admin:
```php
$routes->group('admin', function ($routes) {
    $routes->get('login', '\Myth\Auth\Controllers\AuthController::login', ['as' => 'admin-login']);
    // ... route admin lainnya
});
```

Akses: `http://172.16.11.102/admin/login`

### Opsi 3: Buat Controller Login Wrapper
Buat controller `app/Controllers/Login.php`:
```php
<?php
namespace App\Controllers;

class Login extends BaseController
{
    public function index()
    {
        $authController = new \Myth\Auth\Controllers\AuthController();
        return $authController->login();
    }
}
```

Lalu tambahkan route:
```php
$routes->get('login', 'Login::index', ['as' => 'login']);
```

### Opsi 4: Cek Konfigurasi Nginx
Pastikan Nginx rewrite rules benar di `nginx.conf`:
```nginx
location / {
    try_files $uri $uri/ /index.php?$query_string;
}
```

## Langkah Diagnosa

1. **Cek apakah route terdaftar:**
   ```bash
   php spark routes | grep login
   ```

2. **Cek log error:**
   ```bash
   tail -50 writable/logs/*.php
   sudo tail -50 /var/log/nginx/error.log
   ```

3. **Test akses dengan index.php:**
   ```bash
   curl http://172.16.11.102/index.php/login
   ```

4. **Cek konfigurasi Nginx:**
   ```bash
   sudo nginx -t
   cat nginx.conf | grep -A 10 "location /"
   ```

## Rekomendasi

Coba **Opsi 1** dulu (akses via index.php). Jika bekerja, berarti masalahnya di Nginx rewrite rules.


