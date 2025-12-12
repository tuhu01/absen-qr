#!/bin/bash

# Script lengkap untuk setup aplikasi absen-qr
# Termasuk setup database migration dan nginx
# Jalankan dengan: bash setup-complete.sh

set -e  # Exit on error

echo "=== Setup Lengkap Aplikasi Absen QR ==="
echo ""

# Cek apakah script dijalankan sebagai root atau dengan sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Script ini memerlukan akses root/sudo"
    echo "Jalankan dengan: sudo bash setup-complete.sh"
    exit 1
fi

# 1. Setup .env file
echo "1. Setup file .env..."
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "   ✓ File .env dibuat dari .env.example"
    else
        echo "   ✗ File .env.example tidak ditemukan!"
        exit 1
    fi
else
    echo "   ✓ File .env sudah ada"
fi

# Update baseURL di .env untuk nginx
sed -i "s|app.baseURL = 'http://localhost/absensi-sekolah-qr-code/'|app.baseURL = 'http://localhost/'|g" .env
echo "   ✓ BaseURL diupdate ke http://localhost/"

# 2. Cek konfigurasi database dari .env
echo ""
echo "2. Konfigurasi Database..."
DB_HOST=$(grep "database.default.hostname" .env | cut -d'=' -f2 | tr -d ' ' || echo "localhost")
DB_NAME=$(grep "database.default.database" .env | cut -d'=' -f2 | tr -d ' ' || echo "db_absensi")
DB_USER=$(grep "database.default.username" .env | cut -d'=' -f2 | tr -d ' ' || echo "root")
DB_PASS=$(grep "database.default.password" .env | cut -d'=' -f2 | tr -d ' ' || echo "")

echo "   Host: $DB_HOST"
echo "   Database: $DB_NAME"
echo "   User: $DB_USER"

# 3. Cek apakah MySQL/MariaDB terinstall
if ! command -v mysql &> /dev/null; then
    echo ""
    echo "3. Menginstall MySQL/MariaDB..."
    apt update
    apt install -y mariadb-server mariadb-client
    systemctl start mariadb
    systemctl enable mariadb
    echo "   ✓ MySQL/MariaDB terinstall"
else
    echo ""
    echo "3. MySQL/MariaDB sudah terinstall"
fi

# 4. Buat database jika belum ada
echo ""
echo "4. Membuat database jika belum ada..."
if [ -z "$DB_PASS" ]; then
    mysql -u "$DB_USER" -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" 2>/dev/null || {
        echo "   ⚠ Gagal membuat database. Pastikan MySQL user '$DB_USER' memiliki akses."
        echo "   Atau buat database manual dengan:"
        echo "   mysql -u root -p -e \"CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;\""
        read -p "   Tekan Enter untuk melanjutkan atau Ctrl+C untuk membatalkan..."
    }
else
    mysql -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" 2>/dev/null || {
        echo "   ⚠ Gagal membuat database. Periksa kredensial database di file .env"
        read -p "   Tekan Enter untuk melanjutkan atau Ctrl+C untuk membatalkan..."
    }
fi
echo "   ✓ Database siap"

# 5. Install nginx dan php-fpm
echo ""
echo "5. Menginstall nginx dan php-fpm..."
if ! command -v nginx &> /dev/null; then
    apt update
    apt install -y nginx php-fpm php-mysql php-mbstring php-xml php-curl php-zip
    echo "   ✓ nginx dan php-fpm terinstall"
else
    echo "   ✓ nginx sudah terinstall"
    # Install PHP extensions jika belum ada
    apt install -y php-mysql php-mbstring php-xml php-curl php-zip 2>/dev/null || true
fi

# Deteksi versi PHP
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
echo "   PHP version: $PHP_VERSION"

# 6. Setup konfigurasi nginx
echo ""
echo "6. Setup konfigurasi nginx..."
# Update konfigurasi nginx dengan versi PHP yang benar
sed "s/php8.3-fpm/php${PHP_VERSION}-fpm/g" nginx.conf > /tmp/nginx-absen-qr.conf

# Copy konfigurasi nginx
cp /tmp/nginx-absen-qr.conf /etc/nginx/sites-available/absen-qr
rm /tmp/nginx-absen-qr.conf

# Enable site
ln -sf /etc/nginx/sites-available/absen-qr /etc/nginx/sites-enabled/

# Hapus default site jika ada
if [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi
echo "   ✓ Konfigurasi nginx dibuat"

# 7. Set permission folder writable
echo ""
echo "7. Set permission folder writable..."
chown -R www-data:www-data writable
chmod -R 775 writable
echo "   ✓ Permission folder writable diupdate"

# 8. Test konfigurasi nginx
echo ""
echo "8. Testing konfigurasi nginx..."
if nginx -t; then
    echo "   ✓ Konfigurasi nginx valid"
else
    echo "   ✗ Error: Konfigurasi nginx tidak valid!"
    exit 1
fi

# 9. Restart services
echo ""
echo "9. Restart services..."
systemctl restart nginx
systemctl enable nginx
systemctl restart php${PHP_VERSION}-fpm
systemctl enable php${PHP_VERSION}-fpm
echo "   ✓ Services di-restart"

# 10. Install composer dependencies
echo ""
echo "10. Install composer dependencies..."
if [ ! -d vendor ]; then
    if command -v composer &> /dev/null; then
        composer install --no-interaction
        echo "   ✓ Dependencies terinstall"
    else
        echo "   ⚠ Composer tidak ditemukan. Install dengan: apt install composer"
        echo "   Atau download dari: https://getcomposer.org/"
    fi
else
    echo "   ✓ Dependencies sudah terinstall"
fi

# 11. Jalankan migration
echo ""
echo "11. Menjalankan database migration..."
cd "$(dirname "$0")"
if php spark migrate; then
    echo "   ✓ Migration berhasil"
else
    echo "   ⚠ Migration gagal. Pastikan konfigurasi database di .env sudah benar."
    echo "   Jalankan manual dengan: php spark migrate"
fi

echo ""
echo "=== Setup Selesai! ==="
echo ""
echo "Aplikasi dapat diakses di: http://localhost"
echo ""
echo "Catatan penting:"
echo "- Pastikan konfigurasi database di file .env sudah benar"
echo "- Jika migration gagal, jalankan manual: php spark migrate"
echo "- Untuk melihat log: sudo tail -f /var/log/nginx/absen-qr-error.log"
echo ""
echo "Status services:"
echo "- Nginx: sudo systemctl status nginx"
echo "- PHP-FPM: sudo systemctl status php${PHP_VERSION}-fpm"
echo "- MySQL: sudo systemctl status mariadb"

