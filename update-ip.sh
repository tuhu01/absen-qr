#!/bin/bash

# Script untuk update IP address setelah pindah WiFi
# Otomatis deteksi IP baru dan update konfigurasi

echo "=== Update IP Address Setelah Pindah WiFi ==="
echo ""

# Deteksi IP baru
NEW_IP=$(hostname -I | awk '{print $1}')
echo "IP baru terdeteksi: $NEW_IP"
echo ""

# Cek apakah HTTPS aktif
HTTPS_ACTIVE=false
if sudo netstat -tlnp 2>/dev/null | grep -q ":443"; then
    HTTPS_ACTIVE=true
    PROTOCOL="https"
    echo "HTTPS aktif - menggunakan HTTPS"
else
    PROTOCOL="http"
    echo "HTTPS tidak aktif - menggunakan HTTP"
fi
echo ""

# Update baseURL di app/Config/App.php
echo "Mengupdate baseURL di app/Config/App.php..."
sed -i "s|public string \$baseURL = 'https://[^']*/';|public string \$baseURL = '${PROTOCOL}://${NEW_IP}/';|g" app/Config/App.php
sed -i "s|public string \$baseURL = 'http://[^']*/';|public string \$baseURL = '${PROTOCOL}://${NEW_IP}/';|g" app/Config/App.php
echo "✓ app/Config/App.php updated"
echo ""

# Update .env jika ada
if [ -f .env ]; then
    echo "Mengupdate baseURL di .env..."
    sed -i "s|^app.baseURL = 'https://[^']*/'|app.baseURL = '${PROTOCOL}://${NEW_IP}/'|g" .env
    sed -i "s|^app.baseURL = 'http://[^']*/'|app.baseURL = '${PROTOCOL}://${NEW_IP}/'|g" .env
    echo "✓ .env updated"
    echo ""
fi

# Clear cache
echo "Membersihkan cache..."
rm -rf writable/cache/* 2>/dev/null
echo "✓ Cache cleared"
echo ""

# Restart services
echo "Restarting services..."
sudo systemctl restart php8.3-fpm nginx 2>/dev/null
echo "✓ Services restarted"
echo ""

echo "=== SELESAI ==="
echo ""
echo "IP baru: $NEW_IP"
echo "Protocol: $PROTOCOL"
echo "Base URL: ${PROTOCOL}://${NEW_IP}/"
echo ""
echo "Akses aplikasi di: ${PROTOCOL}://${NEW_IP}/"
echo ""

