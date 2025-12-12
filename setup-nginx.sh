#!/bin/bash

# Script untuk setup nginx untuk aplikasi absen-qr
# Jalankan dengan: bash setup-nginx.sh

echo "=== Setup Nginx untuk Absen QR ==="
echo ""

# Cek apakah script dijalankan sebagai root atau dengan sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Script ini memerlukan akses root/sudo"
    echo "Jalankan dengan: sudo bash setup-nginx.sh"
    exit 1
fi

# Install nginx dan php-fpm
echo "1. Menginstall nginx dan php-fpm..."
apt update
apt install -y nginx php-fpm

# Deteksi versi PHP
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
echo "PHP version terdeteksi: $PHP_VERSION"

# Update konfigurasi nginx dengan versi PHP yang benar
sed -i "s/php8.3-fpm/php${PHP_VERSION}-fpm/g" nginx.conf

# Copy konfigurasi nginx
echo "2. Mengcopy konfigurasi nginx..."
cp nginx.conf /etc/nginx/sites-available/absen-qr

# Enable site
echo "3. Mengaktifkan site..."
ln -sf /etc/nginx/sites-available/absen-qr /etc/nginx/sites-enabled/

# Hapus default site jika ada
if [ -f /etc/nginx/sites-enabled/default ]; then
    echo "4. Menghapus default site..."
    rm /etc/nginx/sites-enabled/default
fi

# Test konfigurasi nginx
echo "5. Testing konfigurasi nginx..."
nginx -t

if [ $? -eq 0 ]; then
    echo "6. Restart nginx..."
    systemctl restart nginx
    systemctl enable nginx
    
    echo "7. Restart php-fpm..."
    systemctl restart php${PHP_VERSION}-fpm
    systemctl enable php${PHP_VERSION}-fpm
    
    echo ""
    echo "=== Setup selesai! ==="
    echo "Aplikasi dapat diakses di: http://localhost"
    echo ""
    echo "Untuk melihat status nginx: sudo systemctl status nginx"
    echo "Untuk melihat log: sudo tail -f /var/log/nginx/absen-qr-error.log"
else
    echo "Error: Konfigurasi nginx tidak valid!"
    exit 1
fi

