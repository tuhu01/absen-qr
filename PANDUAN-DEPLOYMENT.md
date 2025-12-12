# Panduan Deployment ke Server Baru

## Checklist Konfigurasi untuk Server Baru

### 1. Konfigurasi IP Address / BaseURL

**File: `app/Config/App.php`**

```php
public string $baseURL = 'https://IP_SERVER_BARU/';  // atau http:// jika tidak pakai HTTPS
```

**File: `.env`** (jika ada)

```env
app.baseURL = 'https://IP_SERVER_BARU/'
```

**Cara update otomatis:**
```bash
cd /path/to/absen-qr
./update-ip.sh
```

### 2. Konfigurasi Database

**File: `app/Config/Database.php`**

```php
public array $default = [
    'hostname' => 'localhost',  // atau IP database server
    'username' => 'username_db',
    'password' => 'password_db',
    'database' => 'nama_database',
    'DBDriver' => 'MySQLi',
    'port'     => 3306,
];
```

**File: `.env`** (jika menggunakan .env)

```env
database.default.hostname = localhost
database.default.database = nama_database
database.default.username = username_db
database.default.password = password_db
database.default.DBDriver = MySQLi
database.default.port = 3306
```

### 3. File Permissions

**Set permission untuk direktori writable:**

```bash
cd /path/to/absen-qr
sudo chown -R www-data:www-data writable
sudo chmod -R 775 writable/cache writable/logs writable/session writable/uploads
```

### 4. Konfigurasi Nginx

**File: `nginx.conf` atau `/etc/nginx/sites-available/absen-qr`**

Update path root dan server_name:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name IP_SERVER_BARU;  # atau domain jika ada
    
    root /path/to/absen-qr/public;
    index index.php index.html;
    
    # ... konfigurasi lainnya
}
```

**Untuk HTTPS:**
```bash
sudo bash setup-https.sh
```

### 5. Konfigurasi PHP-FPM

**Cek socket PHP-FPM:**

```bash
php -v  # cek versi PHP
ls -la /var/run/php/php*-fpm.sock  # cek socket yang tersedia
```

Update di `nginx.conf`:
```nginx
fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;  # sesuaikan versi PHP
```

### 6. Environment Variables (.env)

**Copy dari `.env.example` jika ada:**

```bash
cp .env.example .env
nano .env
```

**Update variabel penting:**
- `app.baseURL`
- Database credentials
- `CI_ENVIRONMENT` (production/development)

### 7. SSL Certificate (Jika Menggunakan HTTPS)

**Jika menggunakan self-signed certificate:**
```bash
sudo bash setup-https.sh
```

**Jika menggunakan Let's Encrypt:**
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d domain.com
```

### 8. Clear Cache

```bash
cd /path/to/absen-qr
rm -rf writable/cache/*
```

### 9. Restart Services

```bash
sudo systemctl restart php8.3-fpm nginx
# atau sesuaikan versi PHP
sudo systemctl restart php8.1-fpm nginx
```

### 10. Test Akses

```bash
# Test HTTP
curl -I http://IP_SERVER_BARU

# Test HTTPS (jika sudah setup)
curl -I https://IP_SERVER_BARU

# Test route login
curl -I http://IP_SERVER_BARU/login
```

## Langkah-Langkah Deployment Lengkap

### Step 1: Upload File ke Server

```bash
# Via SCP
scp -r absen-qr/ user@server:/path/to/destination/

# Via Git
git clone repository-url
cd absen-qr
```

### Step 2: Install Dependencies

```bash
cd /path/to/absen-qr
composer install --no-dev --optimize-autoloader
```

### Step 3: Setup Database

```bash
# Import database
mysql -u root -p nama_database < database.sql

# Atau buat database baru
mysql -u root -p
CREATE DATABASE nama_database;
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON nama_database.* TO 'username'@'localhost';
FLUSH PRIVILEGES;
```

### Step 4: Konfigurasi Environment

```bash
# Update IP di App.php
nano app/Config/App.php
# Update baseURL ke IP server baru

# Update database di Database.php atau .env
nano app/Config/Database.php
# atau
nano .env
```

### Step 5: Setup Nginx

```bash
# Copy konfigurasi nginx
sudo cp nginx.conf /etc/nginx/sites-available/absen-qr
sudo ln -s /etc/nginx/sites-available/absen-qr /etc/nginx/sites-enabled/

# Update path di nginx.conf
sudo nano /etc/nginx/sites-available/absen-qr

# Test konfigurasi
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### Step 6: Setup Permissions

```bash
cd /path/to/absen-qr
sudo chown -R www-data:www-data writable
sudo chmod -R 775 writable/cache writable/logs writable/session writable/uploads
```

### Step 7: Setup HTTPS (Opsional tapi Disarankan)

```bash
sudo bash setup-https.sh
```

### Step 8: Clear Cache dan Restart

```bash
rm -rf writable/cache/*
sudo systemctl restart php8.3-fpm nginx
```

### Step 9: Test

```bash
# Test akses
curl -I http://IP_SERVER_BARU
curl -I http://IP_SERVER_BARU/login

# Test di browser
# Buka: http://IP_SERVER_BARU atau https://IP_SERVER_BARU
```

## File-File yang Perlu Dikonfigurasi

### Wajib Dikonfigurasi:
1. ✅ `app/Config/App.php` → baseURL
2. ✅ `app/Config/Database.php` → Database credentials
3. ✅ `nginx.conf` → Path root dan server_name
4. ✅ File permissions → writable directories

### Opsional:
5. `.env` → Environment variables (jika digunakan)
6. `app/Config/Session.php` → Session configuration
7. `app/Config/Encryption.php` → Encryption key
8. SSL certificate → Jika menggunakan HTTPS

## Script Otomatis untuk Update IP

Gunakan script `update-ip.sh` untuk update IP otomatis:

```bash
cd /path/to/absen-qr
./update-ip.sh
```

Script ini akan:
- Otomatis deteksi IP baru
- Update baseURL di `App.php` dan `.env`
- Clear cache
- Restart services

## Troubleshooting

### Masalah: Route tidak bekerja
- **Cek:** `app/Config/App.php` → `uriProtocol = 'REQUEST_URI'`
- **Cek:** Route login harus sebelum route `/` di `Routes.php`
- **Restart:** `sudo systemctl restart php8.3-fpm nginx`

### Masalah: Database connection error
- **Cek:** Database credentials di `Database.php` atau `.env`
- **Cek:** Database server running: `sudo systemctl status mysql`
- **Cek:** User memiliki permission: `SHOW GRANTS FOR 'user'@'localhost';`

### Masalah: Permission denied
- **Fix:** `sudo chown -R www-data:www-data writable`
- **Fix:** `sudo chmod -R 775 writable/*`

### Masalah: CSS/JS tidak ter-load
- **Cek:** baseURL sudah benar di `App.php`
- **Cek:** Nginx bisa akses file di `public/assets/`
- **Clear cache:** `rm -rf writable/cache/*`

### Masalah: Kamera tidak bisa diakses
- **Solusi:** Setup HTTPS dengan `sudo bash setup-https.sh`
- **Atau:** Akses via localhost/127.0.0.1

## Checklist Final

Sebelum production, pastikan:
- [ ] BaseURL sudah benar
- [ ] Database credentials sudah benar
- [ ] File permissions sudah benar
- [ ] Nginx configuration sudah benar
- [ ] PHP-FPM running
- [ ] Cache cleared
- [ ] Services restarted
- [ ] Test akses berhasil
- [ ] Test login berhasil
- [ ] Test scan QR berhasil (jika HTTPS sudah setup)

## Catatan Penting

1. **Jangan commit file `.env`** ke repository (masukkan ke `.gitignore`)
2. **Gunakan HTTPS** untuk production (kamera memerlukan HTTPS)
3. **Backup database** sebelum deployment
4. **Test semua fitur** setelah deployment
5. **Monitor log** untuk error: `tail -f writable/logs/*.php`
