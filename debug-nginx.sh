#!/bin/bash

# Script debugging untuk error 404 nginx
# Jalankan dengan: sudo bash debug-nginx.sh

if [ "$EUID" -ne 0 ]; then 
    echo "Jalankan dengan: sudo bash debug-nginx.sh"
    exit 1
fi

echo "=== Debugging Nginx 404 Error ==="
echo ""

# 1. Cek file index.php
echo "1. Cek file index.php..."
INDEX_FILE="/home/tuhu-pangestu/college/absen-qr/public/index.php"
if [ -f "$INDEX_FILE" ]; then
    echo "   ✓ File index.php ada: $INDEX_FILE"
    ls -lh "$INDEX_FILE"
else
    echo "   ✗ File index.php TIDAK ADA: $INDEX_FILE"
    exit 1
fi

# 2. Cek document root di konfigurasi nginx
echo ""
echo "2. Cek konfigurasi nginx..."
NGINX_ROOT=$(grep -E "^[[:space:]]*root" /etc/nginx/sites-available/absen-qr | head -1 | awk '{print $2}' | tr -d ';')
echo "   Document root di nginx: $NGINX_ROOT"

if [ -d "$NGINX_ROOT" ]; then
    echo "   ✓ Directory ada"
    if [ -f "$NGINX_ROOT/index.php" ]; then
        echo "   ✓ File index.php ada di document root"
    else
        echo "   ✗ File index.php TIDAK ADA di document root!"
    fi
else
    echo "   ✗ Directory TIDAK ADA!"
fi

# 3. Cek permission
echo ""
echo "3. Cek permission..."
ls -ld "$(dirname $INDEX_FILE)"
ls -l "$INDEX_FILE"

# 4. Cek nginx status
echo ""
echo "4. Cek nginx status..."
systemctl status nginx --no-pager -l | head -15

# 5. Cek PHP-FPM status
echo ""
echo "5. Cek PHP-FPM status..."
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
systemctl status php${PHP_VERSION}-fpm --no-pager -l | head -10 || systemctl status php-fpm --no-pager -l | head -10

# 6. Cek log error terakhir
echo ""
echo "6. Log error terakhir (10 baris):"
tail -10 /var/log/nginx/absen-qr-error.log 2>/dev/null || echo "   Log tidak ditemukan"

# 7. Test konfigurasi nginx
echo ""
echo "7. Test konfigurasi nginx..."
nginx -t

# 8. Cek apakah nginx membaca file yang benar
echo ""
echo "8. Cek file yang dibaca nginx..."
echo "   Sites enabled:"
ls -la /etc/nginx/sites-enabled/

# 9. Test akses file langsung
echo ""
echo "9. Test akses file..."
if [ -f "$INDEX_FILE" ]; then
    echo "   Testing: cat $INDEX_FILE | head -5"
    head -5 "$INDEX_FILE"
fi

# 10. Cek socket PHP-FPM
echo ""
echo "10. Cek PHP-FPM socket..."
PHP_SOCKET="/var/run/php/php${PHP_VERSION}-fpm.sock"
if [ -S "$PHP_SOCKET" ]; then
    echo "   ✓ Socket ada: $PHP_SOCKET"
    ls -l "$PHP_SOCKET"
else
    echo "   ✗ Socket TIDAK ADA: $PHP_SOCKET"
    echo "   Mencari socket yang tersedia..."
    ls -l /var/run/php/*.sock 2>/dev/null || echo "   Tidak ada socket ditemukan"
fi

echo ""
echo "=== Selesai Debugging ==="
echo ""
echo "Jika ada masalah, perbaiki sesuai output di atas."

