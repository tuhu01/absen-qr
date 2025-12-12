#!/bin/bash

# Script untuk switch dari Apache2 ke Nginx
# Jalankan dengan: sudo bash switch-to-nginx.sh

echo "=== Switch dari Apache2 ke Nginx ==="
echo ""

if [ "$EUID" -ne 0 ]; then 
    echo "Script ini memerlukan akses root/sudo"
    echo "Jalankan dengan: sudo bash switch-to-nginx.sh"
    exit 1
fi

# 1. Stop Apache2
echo "1. Menghentikan Apache2..."
if systemctl is-active --quiet apache2; then
    systemctl stop apache2
    systemctl disable apache2
    echo "   ✓ Apache2 dihentikan dan dinonaktifkan"
else
    echo "   ✓ Apache2 sudah tidak berjalan"
fi

# 2. Pastikan nginx terinstall
echo ""
echo "2. Mengecek nginx..."
if ! command -v nginx &> /dev/null; then
    echo "   Nginx belum terinstall, menginstall..."
    apt update 2>&1 | grep -vE "(NO_PUBKEY|GPG error|not signed)" || true
    apt install -y nginx php-fpm php-mysql php-mbstring php-xml php-curl php-zip
    echo "   ✓ Nginx terinstall"
else
    echo "   ✓ Nginx sudah terinstall"
fi

# 3. Setup konfigurasi nginx
echo ""
echo "3. Setup konfigurasi nginx..."
cd "$(dirname "$0")"

# Deteksi versi PHP
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
echo "   PHP version: $PHP_VERSION"

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

# 4. Set permission folder writable
echo ""
echo "4. Set permission folder writable..."
chown -R www-data:www-data writable
chmod -R 775 writable
echo "   ✓ Permission folder writable diupdate"

# 5. Test konfigurasi nginx
echo ""
echo "5. Testing konfigurasi nginx..."
if nginx -t; then
    echo "   ✓ Konfigurasi nginx valid"
else
    echo "   ✗ Error: Konfigurasi nginx tidak valid!"
    exit 1
fi

# 6. Start nginx
echo ""
echo "6. Menjalankan nginx..."
systemctl start nginx
systemctl enable nginx

# Restart PHP-FPM
systemctl restart php${PHP_VERSION}-fpm
systemctl enable php${PHP_VERSION}-fpm

echo "   ✓ Nginx dijalankan"

# 7. Verifikasi
echo ""
echo "7. Verifikasi..."
sleep 2
if systemctl is-active --quiet nginx; then
    echo "   ✓ Nginx berjalan dengan baik"
else
    echo "   ✗ Nginx gagal berjalan, cek log: sudo journalctl -u nginx"
    exit 1
fi

# Cek port 80
if ss -tlnp | grep -q ":80.*nginx" || netstat -tlnp 2>/dev/null | grep -q ":80.*nginx"; then
    echo "   ✓ Nginx mendengarkan di port 80"
else
    echo "   ⚠ Port 80 mungkin masih digunakan oleh service lain"
fi

echo ""
echo "=== Selesai! ==="
echo ""
echo "Apache2 sudah dihentikan dan nginx sudah berjalan."
echo ""
echo "Aplikasi dapat diakses di:"
echo "  http://$(hostname -I | awk '{print $1}')"
echo ""
echo "Jika masih melihat halaman default, coba:"
echo "  1. Clear cache browser"
echo "  2. Cek: sudo systemctl status nginx"
echo "  3. Cek log: sudo tail -f /var/log/nginx/absen-qr-error.log"

