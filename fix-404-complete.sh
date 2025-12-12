#!/bin/bash

# Script lengkap untuk fix error 404 nginx
# Jalankan dengan: sudo bash fix-404-complete.sh

if [ "$EUID" -ne 0 ]; then 
    echo "Jalankan dengan: sudo bash fix-404-complete.sh"
    exit 1
fi

set -e

cd "$(dirname "$0")"

echo "=== Fix Error 404 Nginx - Lengkap ==="
echo ""

# 1. Deteksi PHP version dan socket
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
PHP_SOCKET="/var/run/php/php${PHP_VERSION}-fpm.sock"

echo "PHP Version: $PHP_VERSION"
echo "PHP Socket: $PHP_SOCKET"

# Cek socket
if [ ! -S "$PHP_SOCKET" ]; then
    echo "⚠ Socket tidak ditemukan, mencari alternatif..."
    ALT_SOCKET=$(ls /var/run/php/*.sock 2>/dev/null | head -1)
    if [ -n "$ALT_SOCKET" ]; then
        PHP_SOCKET="$ALT_SOCKET"
        echo "Menggunakan socket: $PHP_SOCKET"
    else
        echo "✗ PHP-FPM socket tidak ditemukan!"
        echo "Menginstall PHP-FPM..."
        apt install -y php-fpm
        systemctl start php${PHP_VERSION}-fpm
        systemctl enable php${PHP_VERSION}-fpm
    fi
fi

# 2. Update nginx.conf dengan socket yang benar
echo ""
echo "1. Update konfigurasi nginx..."
sed "s|fastcgi_pass unix:/var/run/php/php[0-9.]*-fpm.sock|fastcgi_pass unix:${PHP_SOCKET}|g" nginx.conf > /tmp/nginx-updated.conf

# 3. Copy ke nginx
echo "2. Copy konfigurasi ke nginx..."
cp /tmp/nginx-updated.conf /etc/nginx/sites-available/absen-qr
rm /tmp/nginx-updated.conf

# 4. Enable site
echo "3. Enable site..."
ln -sf /etc/nginx/sites-available/absen-qr /etc/nginx/sites-enabled/

# Hapus default
if [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi

# 5. Set permission
echo "4. Set permission..."
chown -R www-data:www-data writable
chmod -R 775 writable

# Pastikan www-data bisa baca folder public
chmod 755 /home/tuhu-pangestu/college/absen-qr
chmod 755 /home/tuhu-pangestu/college/absen-qr/public
chmod 644 /home/tuhu-pangestu/college/absen-qr/public/index.php

# 6. Test konfigurasi
echo "5. Test konfigurasi..."
if ! nginx -t; then
    echo "✗ Konfigurasi nginx tidak valid!"
    nginx -t
    exit 1
fi

# 7. Start/restart services
echo "6. Start services..."

# Start PHP-FPM
systemctl start php${PHP_VERSION}-fpm 2>/dev/null || systemctl start php-fpm
systemctl enable php${PHP_VERSION}-fpm 2>/dev/null || systemctl enable php-fpm

# Restart nginx
systemctl restart nginx
systemctl enable nginx

# 8. Verifikasi
echo ""
echo "7. Verifikasi..."
sleep 2

# Cek nginx
if systemctl is-active --quiet nginx; then
    echo "   ✓ Nginx berjalan"
else
    echo "   ✗ Nginx tidak berjalan"
    systemctl status nginx --no-pager -l | tail -5
fi

# Cek PHP-FPM
if systemctl is-active --quiet php${PHP_VERSION}-fpm || systemctl is-active --quiet php-fpm; then
    echo "   ✓ PHP-FPM berjalan"
else
    echo "   ✗ PHP-FPM tidak berjalan"
fi

# Test file
if [ -f "/home/tuhu-pangestu/college/absen-qr/public/index.php" ]; then
    echo "   ✓ File index.php ada"
else
    echo "   ✗ File index.php tidak ada!"
fi

# 9. Test akses
echo ""
echo "8. Test akses..."
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "   Test dari server: curl -I http://localhost"
curl -I http://localhost 2>&1 | head -3 || echo "   ⚠ Curl test gagal"

echo ""
echo "=== Selesai! ==="
echo ""
echo "Aplikasi seharusnya bisa diakses di:"
echo "  http://${SERVER_IP}"
echo "  http://localhost"
echo ""
echo "Jika masih error 404, jalankan debugging:"
echo "  sudo bash debug-nginx.sh"
echo ""
echo "Atau cek log:"
echo "  sudo tail -f /var/log/nginx/absen-qr-error.log"

