# Instruksi Setup Aplikasi Absen QR di Nginx

## Persiapan

### 1. Konfigurasi Database

Edit file `.env` dan pastikan konfigurasi database sudah benar:

```bash
nano .env
```

Atau edit dengan editor lain. Pastikan bagian database seperti ini:

```
database.default.hostname = localhost
database.default.database = db_absensi
database.default.username = root
database.default.password = <password_mysql_anda>
database.default.DBDriver = MySQLi
database.default.port = 3306
```

**Penting:** Ganti `<password_mysql_anda>` dengan password MySQL root Anda. Jika MySQL root tidak punya password, biarkan kosong.

### 2. Buat Database (Jika Belum Ada)

Buat database `db_absensi` di MySQL:

```bash
# Jika MySQL root tidak punya password:
mysql -u root -e "CREATE DATABASE IF NOT EXISTS db_absensi CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"

# Jika MySQL root punya password:
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS db_absensi CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
```

## Setup Otomatis

Setelah konfigurasi database selesai, jalankan script setup:

```bash
sudo bash setup-complete.sh
```

Script ini akan:
1. ✅ Setup file .env (jika belum ada)
2. ✅ Install MySQL/MariaDB (jika belum ada)
3. ✅ Buat database (jika belum ada)
4. ✅ Install nginx dan php-fpm
5. ✅ Setup konfigurasi nginx
6. ✅ Set permission folder writable
7. ✅ Install composer dependencies
8. ✅ Jalankan database migration
9. ✅ Enable dan start services

## Setup Manual

Jika script otomatis tidak berjalan, ikuti langkah berikut:

### 1. Install Dependencies

```bash
# Install composer dependencies
composer install

# Install nginx dan php-fpm
sudo apt update
sudo apt install -y nginx php-fpm php-mysql php-mbstring php-xml php-curl php-zip
```

### 2. Setup Nginx

```bash
# Copy konfigurasi
sudo cp nginx.conf /etc/nginx/sites-available/absen-qr

# Deteksi versi PHP dan update konfigurasi
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
sudo sed -i "s/php8.3-fpm/php${PHP_VERSION}-fpm/g" /etc/nginx/sites-available/absen-qr

# Enable site
sudo ln -s /etc/nginx/sites-available/absen-qr /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Test konfigurasi
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
```

### 3. Setup PHP-FPM

```bash
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
sudo systemctl restart php${PHP_VERSION}-fpm
sudo systemctl enable php${PHP_VERSION}-fpm
```

### 4. Set Permission

```bash
sudo chown -R www-data:www-data /home/tuhu-pangestu/college/absen-qr/writable
sudo chmod -R 775 /home/tuhu-pangestu/college/absen-qr/writable
```

### 5. Jalankan Migration

```bash
php spark migrate
```

## Verifikasi

Setelah setup selesai, akses aplikasi di:
- **http://localhost**

## Troubleshooting

### Database Connection Error

Jika migration gagal dengan error "Access denied":
1. Pastikan password MySQL di file `.env` sudah benar
2. Pastikan user MySQL memiliki akses ke database
3. Buat database manual jika belum ada:
   ```bash
   mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS db_absensi CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
   ```

### Nginx Error

Cek log error:
```bash
sudo tail -f /var/log/nginx/absen-qr-error.log
```

Test konfigurasi:
```bash
sudo nginx -t
```

### PHP-FPM Error

Cek versi PHP dan socket:
```bash
php -v
ls /var/run/php/
```

Edit `/etc/nginx/sites-available/absen-qr` dan sesuaikan baris:
```
fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
```
dengan versi PHP yang sesuai.

### Permission Error

Jika ada error permission pada folder writable:
```bash
sudo chown -R www-data:www-data /home/tuhu-pangestu/college/absen-qr/writable
sudo chmod -R 775 /home/tuhu-pangestu/college/absen-qr/writable
```

## Catatan

- Base URL aplikasi: `http://localhost/`
- Document root: `/home/tuhu-pangestu/college/absen-qr/public`
- Database: `db_absensi`
- Folder `writable` harus bisa ditulis oleh web server (www-data)

