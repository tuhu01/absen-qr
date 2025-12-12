#!/bin/bash

# Quick fix untuk error 404 nginx
# Jalankan dengan: sudo bash quick-fix-nginx.sh

if [ "$EUID" -ne 0 ]; then 
    echo "Jalankan dengan: sudo bash quick-fix-nginx.sh"
    exit 1
fi

cd "$(dirname "$0")"

PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
PHP_SOCKET="/var/run/php/php${PHP_VERSION}-fpm.sock"

echo "PHP: $PHP_VERSION"
echo "Socket: $PHP_SOCKET"
echo ""

# Update nginx.conf dengan socket yang benar
sed "s|fastcgi_pass unix:/var/run/php/php[0-9.]*-fpm.sock|fastcgi_pass unix:${PHP_SOCKET}|g" nginx.conf > /tmp/nginx-fix.conf

# Copy ke nginx
cp /tmp/nginx-fix.conf /etc/nginx/sites-available/absen-qr
rm /tmp/nginx-fix.conf

# Test dan restart
nginx -t && systemctl reload nginx && echo "✓ Nginx di-reload" || echo "✗ Error"

echo ""
echo "Coba akses: http://$(hostname -I | awk '{print $1}')"

