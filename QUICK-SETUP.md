# Quick Setup - Akses dari Komputer Lain

## Status Setup

✅ **Sudah dikonfigurasi:**
- BaseURL diupdate ke `http://172.16.11.102/`
- Konfigurasi nginx untuk network access
- Composer dependencies terinstall
- File .env sudah dibuat

⚠️ **Perlu dilakukan:**
1. Set password MySQL di file `.env`
2. Buat database dan jalankan migration
3. Setup nginx (butuh sudo)

## Langkah Setup

### 1. Edit Password Database

Edit file `.env`:
```bash
nano .env
```

Cari baris:
```
database.default.password = 
```

Jika MySQL root punya password, isi password-nya:
```
database.default.password = password_anda
```

Jika MySQL root tidak punya password, biarkan kosong (sudah benar).

### 2. Buat Database

Buka terminal dan jalankan:

**Jika MySQL root tidak punya password:**
```bash
mysql -u root -e "CREATE DATABASE IF NOT EXISTS db_absensi CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
```

**Jika MySQL root punya password:**
```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS db_absensi CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
```

### 3. Jalankan Migration

```bash
php spark migrate
```

### 4. Setup Nginx (Butuh Sudo)

Jalankan script setup lengkap:
```bash
sudo bash setup-network.sh
```

Script ini akan:
- Install nginx dan php-fpm (jika belum ada)
- Setup konfigurasi nginx
- Set permission folder
- Restart services
- Konfigurasi firewall

### 5. Verifikasi

Setelah setup selesai, akses dari komputer lain:
- **http://172.16.11.102**

## Troubleshooting

### Database Connection Error

Jika error "Access denied":
1. Pastikan password di `.env` benar
2. Coba buat database manual (lihat langkah 2)
3. Cek user MySQL memiliki akses:
   ```bash
   mysql -u root -p -e "SHOW GRANTS FOR 'root'@'localhost';"
   ```

### Tidak Bisa Diakses dari Komputer Lain

1. **Cek nginx status:**
   ```bash
   sudo systemctl status nginx
   ```

2. **Cek firewall:**
   ```bash
   sudo ufw status
   sudo ufw allow 80/tcp
   ```

3. **Cek IP server:**
   ```bash
   hostname -I
   ```

4. **Test dari server sendiri:**
   ```bash
   curl http://172.16.11.102
   ```

5. **Cek log nginx:**
   ```bash
   sudo tail -f /var/log/nginx/absen-qr-error.log
   ```

### Permission Error

Jika ada error permission pada folder writable:
```bash
sudo chown -R www-data:www-data /home/tuhu-pangestu/college/absen-qr/writable
sudo chmod -R 775 /home/tuhu-pangestu/college/absen-qr/writable
```

## Informasi Server

- **IP Server:** 172.16.11.102
- **URL Aplikasi:** http://172.16.11.102
- **Database:** db_absensi
- **Document Root:** /home/tuhu-pangestu/college/absen-qr/public

