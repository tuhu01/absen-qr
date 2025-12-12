#!/bin/bash

# Script untuk apply konfigurasi nginx yang sudah diperbaiki
# Jalankan dengan: sudo bash apply-nginx-config.sh

if [ "$EUID" -ne 0 ]; then 
    echo "Jalankan dengan: sudo bash apply-nginx-config.sh"
    exit 1
fi

cd "$(dirname "$0")"

PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
PHP_SOCKET="/var/run/php/php${PHP_VERSION}-fpm.sock"

echo "=== Apply Konfigurasi Nginx ==="
echo "PHP Version: $PHP_VERSION"
echo "PHP Socket: $PHP_SOCKET"
echo ""

# Update socket di nginx.conf
sed "s|fastcgi_pass unix:/var/run/php/php[0-9.]*-fpm.sock|fastcgi_pass unix:${PHP_SOCKET}|g" nginx.conf > /tmp/nginx-updated.conf

# Copy ke nginx
cp /tmp/nginx-updated.conf /etc/nginx/sites-available/absen-qr
rm /tmp/nginx-updated.conf

# Test konfigurasi
echo "Testing konfigurasi..."
if nginx -t; then
    echo "✓ Konfigurasi valid"
    
    # Reload nginx
    systemctl reload nginx
    echo "✓ Nginx di-reload"
    
    # Restart PHP-FPM
    systemctl restart php${PHP_VERSION}-fpm 2>/dev/null || systemctl restart php-fpm
    echo "✓ PHP-FPM di-restart"
    
    echo ""
    echo "=== Selesai ==="
    echo "Coba akses: http://$(hostname -I | awk '{print $1}')"
else
    echo "✗ Error: Konfigurasi tidak valid!"
    nginx -t
    exit 1
fi

