# Cara Restart PHP-FPM dan Nginx

## Masalah
Route `/login` tidak menampilkan form login karena PHP-FPM dan Nginx perlu di-restart setelah mengubah `Routes.php`.

## Solusi

### Opsi 1: Restart dengan Sudo (Recommended)

Jalankan perintah berikut di terminal:

```bash
sudo systemctl restart php8.3-fpm
sudo systemctl restart nginx
```

Atau restart sekaligus:

```bash
sudo systemctl restart php8.3-fpm nginx
```

### Opsi 2: Menggunakan Script

Jalankan script yang sudah dibuat:

```bash
bash restart-services.sh
```

Script akan meminta password sudo.

### Opsi 3: Reload (Tanpa Restart Penuh)

Jika tidak bisa restart, coba reload:

```bash
sudo systemctl reload php8.3-fpm
sudo systemctl reload nginx
```

### Opsi 4: Menggunakan Service Command

```bash
sudo service php8.3-fpm restart
sudo service nginx restart
```

## Verifikasi

Setelah restart, cek status:

```bash
sudo systemctl status php8.3-fpm
sudo systemctl status nginx
```

Keduanya harus menunjukkan status "active (running)".

## Test

Setelah restart, akses:
- URL: `http://172.16.11.102/login`
- Seharusnya menampilkan form login, bukan halaman scan QR

## Catatan

- **PENTING:** Route tidak akan bekerja sampai PHP-FPM di-restart
- PHP version yang digunakan: **8.3**
- Service name: `php8.3-fpm.service`

