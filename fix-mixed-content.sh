#!/bin/bash

# Script untuk fix mixed content dan ensure semua assets menggunakan HTTPS
# Jalankan dengan: sudo bash fix-mixed-content.sh

if [ "$EUID" -ne 0 ]; then 
    echo "Jalankan dengan: sudo bash fix-mixed-content.sh"
    exit 1
fi

echo "=== Fix Mixed Content & Ensure HTTPS ==="
echo ""

cd "$(dirname "$0")"

SERVER_IP=$(hostname -I | awk '{print $1}')

# 1. Pastikan baseURL HTTPS
echo "1. Update baseURL ke HTTPS..."
sed -i "s|app.baseURL = '.*'|app.baseURL = 'https://${SERVER_IP}/'|g" .env
sed -i "s|public string \$baseURL = '.*';|public string \$baseURL = 'https://${SERVER_IP}/';|g" app/Config/App.php
echo "   ✓ BaseURL: https://${SERVER_IP}/"

# 2. Pastikan konfigurasi HTTPS aktif dan HTTP redirect
echo "2. Verifikasi konfigurasi nginx..."
if [ ! -f /etc/nginx/sites-available/absen-qr-https ]; then
    echo "   ⚠ Konfigurasi HTTPS tidak ada, jalankan: sudo bash setup-https.sh"
    exit 1
fi

# Enable HTTPS config
ln -sf /etc/nginx/sites-available/absen-qr-https /etc/nginx/sites-enabled/

# Disable HTTP config (kecuali untuk redirect)
if [ -f /etc/nginx/sites-enabled/absen-qr ] && [ ! -L /etc/nginx/sites-enabled/absen-qr-https ]; then
    rm /etc/nginx/sites-enabled/absen-qr
fi

# 3. Pastikan certificate ada
echo "3. Verifikasi certificate..."
if [ ! -f /etc/nginx/ssl/absen-qr.crt ] || [ ! -f /etc/nginx/ssl/absen-qr.key ]; then
    echo "   ⚠ Certificate tidak ada, generate..."
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/absen-qr.key \
        -out /etc/nginx/ssl/absen-qr.crt \
        -subj "/C=ID/ST=Jakarta/L=Jakarta/O=AbsenQR/CN=${SERVER_IP}" \
        2>/dev/null
    chmod 600 /etc/nginx/ssl/absen-qr.key
    chmod 644 /etc/nginx/ssl/absen-qr.crt
fi
echo "   ✓ Certificate ada"

# 4. Update nginx config untuk force HTTPS dan security headers
echo "4. Update konfigurasi nginx untuk security headers..."
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
PHP_SOCKET="/var/run/php/php${PHP_VERSION}-fpm.sock"

# Update security headers di konfigurasi HTTPS
if grep -q "add_header Strict-Transport-Security" /etc/nginx/sites-available/absen-qr-https; then
    echo "   ✓ HSTS header sudah ada"
else
    # Add HSTS header
    sed -i '/add_header X-XSS-Protection/a\    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;' /etc/nginx/sites-available/absen-qr-https
    echo "   ✓ HSTS header ditambahkan"
fi

# 5. Test dan reload
echo "5. Test dan reload nginx..."
if nginx -t 2>/dev/null; then
    systemctl reload nginx
    echo "   ✓ Nginx di-reload"
else
    echo "   ✗ Konfigurasi error"
    nginx -t
    exit 1
fi

# 6. Test akses
echo "6. Test akses..."
sleep 1
if curl -k -s -o /dev/null -w "%{http_code}" https://${SERVER_IP} | grep -q "200"; then
    echo "   ✓ HTTPS berjalan"
else
    echo "   ✗ HTTPS tidak berjalan"
fi

echo ""
echo "=== Selesai! ==="
echo ""
echo "PENTING: Masalah CSS merah di Network tab berarti:"
echo ""
echo "1. Certificate BELUM di-accept di browser"
echo "   → Akses https://${SERVER_IP}"
echo "   → Klik 'Advanced' → 'Proceed to ${SERVER_IP} (unsafe)'"
echo ""
echo "2. Setelah accept certificate:"
echo "   → Clear cache (Ctrl+Shift+Delete)"
echo "   → Hard reload (Ctrl+F5)"
echo "   → CSS akan berubah dari merah ke hijau (200 OK)"
echo ""
echo "3. Jika masih merah setelah accept certificate:"
echo "   → Cek console (F12) untuk error detail"
echo "   → Pastikan tidak ada mixed content warning"
echo "   → Coba incognito mode"

