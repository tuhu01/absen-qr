#!/bin/bash

# Script untuk memperbaiki error 404 nginx
# Jalankan dengan: sudo bash fix-nginx-404.sh

echo "=== Memperbaiki Error 404 Nginx ==="
echo ""

if [ "$EUID" -ne 0 ]; then 
    echo "Script ini memerlukan akses root/sudo"
    echo "Jalankan dengan: sudo bash fix-nginx-404.sh"
    exit 1
fi

cd "$(dirname "$0")"

# 1. Deteksi versi PHP
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
echo "PHP version: $PHP_VERSION"

# Cek PHP-FPM socket
PHP_SOCKET="/var/run/php/php${PHP_VERSION}-fpm.sock"
if [ ! -S "$PHP_SOCKET" ]; then
    echo "⚠ PHP-FPM socket tidak ditemukan di $PHP_SOCKET"
    echo "Mencari socket yang tersedia..."
    PHP_SOCKET=$(ls /var/run/php/*.sock 2>/dev/null | head -1)
    if [ -z "$PHP_SOCKET" ]; then
        echo "✗ PHP-FPM socket tidak ditemukan. Pastikan PHP-FPM terinstall dan berjalan."
        exit 1
    fi
    echo "Menggunakan socket: $PHP_SOCKET"
    PHP_VERSION=$(basename "$PHP_SOCKET" | sed 's/php\([0-9]\+\.[0-9]\+\).*/\1/')
fi

echo "Menggunakan PHP-FPM socket: $PHP_SOCKET"
echo ""

# 2. Update konfigurasi nginx dengan versi PHP yang benar
echo "1. Update konfigurasi nginx..."
sed "s|fastcgi_pass unix:/var/run/php/php[0-9.]*-fpm.sock|fastcgi_pass unix:${PHP_SOCKET}|g" nginx.conf > /tmp/nginx-absen-qr.conf

# 3. Copy konfigurasi ke nginx
echo "2. Copy konfigurasi nginx..."
cp /tmp/nginx-absen-qr.conf /etc/nginx/sites-available/absen-qr
rm /tmp/nginx-absen-qr.conf

# 4. Enable site
echo "3. Enable site nginx..."
ln -sf /etc/nginx/sites-available/absen-qr /etc/nginx/sites-enabled/

# Hapus default site jika ada
if [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
    echo "   ✓ Default site dihapus"
fi

# 5. Set permission
echo "4. Set permission folder..."
chown -R www-data:www-data writable
chmod -R 775 writable
echo "   ✓ Permission diupdate"

# 6. Test konfigurasi
echo "5. Test konfigurasi nginx..."
if nginx -t; then
    echo "   ✓ Konfigurasi nginx valid"
else
    echo "   ✗ Error: Konfigurasi nginx tidak valid!"
    echo "   Cek error di atas"
    exit 1
fi

# 7. Restart nginx
echo "6. Restart nginx..."
systemctl restart nginx

# Restart PHP-FPM
systemctl restart php${PHP_VERSION}-fpm 2>/dev/null || systemctl restart php-fpm

echo "   ✓ Nginx dan PHP-FPM di-restart"

# 8. Verifikasi
echo ""
echo "7. Verifikasi..."
sleep 2

if systemctl is-active --quiet nginx; then
    echo "   ✓ Nginx berjalan"
else
    echo "   ✗ Nginx tidak berjalan"
    systemctl status nginx --no-pager -l | tail -10
    exit 1
fi

# Test file index.php
if [ -f "/home/tuhu-pangestu/college/absen-qr/public/index.php" ]; then
    echo "   ✓ File index.php ditemukan"
else
    echo "   ✗ File index.php tidak ditemukan!"
    exit 1
fi

# Test PHP-FPM
if systemctl is-active --quiet php${PHP_VERSION}-fpm || systemctl is-active --quiet php-fpm; then
    echo "   ✓ PHP-FPM berjalan"
else
    echo "   ⚠ PHP-FPM mungkin tidak berjalan"
fi

echo ""
echo "=== Selesai! ==="
echo ""
echo "Coba akses aplikasi di:"
echo "  http://$(hostname -I | awk '{print $1}')"
echo ""
echo "Jika masih error 404, cek:"
echo "  1. sudo tail -f /var/log/nginx/absen-qr-error.log"
echo "  2. sudo systemctl status nginx"
echo "  3. sudo systemctl status php${PHP_VERSION}-fpm"
echo ""
echo "Test dari server:"
echo "  curl http://localhost"

