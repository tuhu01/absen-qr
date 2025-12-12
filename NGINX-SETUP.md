# Setup Nginx untuk Aplikasi Absen QR

## Instalasi dan Konfigurasi

### 1. Jalankan Script Setup Otomatis

```bash
sudo bash setup-nginx.sh
```

Script ini akan:
- Menginstall nginx dan php-fpm
- Mengcopy konfigurasi nginx ke `/etc/nginx/sites-available/absen-qr`
- Mengaktifkan site dan menghapus default site
- Restart nginx dan php-fpm

### 2. Setup Manual (Alternatif)

Jika script otomatis tidak berjalan, ikuti langkah berikut:

#### Install nginx dan php-fpm:
```bash
sudo apt update
sudo apt install -y nginx php-fpm
```

#### Copy konfigurasi:
```bash
sudo cp nginx.conf /etc/nginx/sites-available/absen-qr
```

#### Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/absen-qr /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default  # Hapus default site
```

#### Test dan restart:
```bash
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl restart php8.3-fpm  # Sesuaikan dengan versi PHP Anda
sudo systemctl enable nginx
sudo systemctl enable php8.3-fpm
```

### 3. Set Permission Folder Writable

Pastikan folder `writable` memiliki permission yang benar:

```bash
sudo chown -R www-data:www-data /home/tuhu-pangestu/college/absen-qr/writable
sudo chmod -R 775 /home/tuhu-pangestu/college/absen-qr/writable
```

### 4. Akses Aplikasi

Setelah setup selesai, aplikasi dapat diakses di:
- **http://localhost**

## Troubleshooting

### Cek Status Nginx
```bash
sudo systemctl status nginx
```

### Cek Log Error
```bash
sudo tail -f /var/log/nginx/absen-qr-error.log
```

### Cek Log Access
```bash
sudo tail -f /var/log/nginx/absen-qr-access.log
```

### Test Konfigurasi Nginx
```bash
sudo nginx -t
```

### Restart Services
```bash
sudo systemctl restart nginx
sudo systemctl restart php8.3-fpm
```

### Cek Versi PHP-FPM
```bash
php -v
ls /var/run/php/  # Lihat socket yang tersedia
```

Jika versi PHP berbeda, edit file `/etc/nginx/sites-available/absen-qr` dan sesuaikan baris:
```
fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
```
dengan versi PHP yang sesuai.

## Catatan

- Base URL aplikasi sudah diupdate ke `http://localhost/`
- Document root diarahkan ke folder `public/` (sesuai standar CodeIgniter 4)
- Folder `writable`, `app`, `tests`, `vendor`, `system`, dan `builds` diblokir dari akses langsung untuk keamanan

