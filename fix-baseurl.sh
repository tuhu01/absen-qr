#!/bin/bash

# Script untuk fix baseURL agar sesuai dengan protokol yang digunakan
# Jalankan dengan: bash fix-baseurl.sh

echo "=== Fix BaseURL untuk CSS dan Assets ==="
echo ""

cd "$(dirname "$0")"

SERVER_IP=$(hostname -I | awk '{print $1}')

# Cek apakah HTTPS sudah aktif
if curl -k -s -o /dev/null -w "%{http_code}" https://${SERVER_IP} | grep -q "200\|301\|302"; then
    PROTOCOL="https"
    echo "HTTPS terdeteksi aktif"
else
    PROTOCOL="http"
    echo "Menggunakan HTTP (HTTPS belum aktif)"
fi

echo ""
echo "Update baseURL ke: ${PROTOCOL}://${SERVER_IP}/"
echo ""

# Update .env
if [ -f .env ]; then
    sed -i "s|app.baseURL = '.*'|app.baseURL = '${PROTOCOL}://${SERVER_IP}/'|g" .env
    echo "✓ .env diupdate"
fi

# Update App.php
sed -i "s|public string \$baseURL = '.*';|public string \$baseURL = '${PROTOCOL}://${SERVER_IP}/';|g" app/Config/App.php
echo "✓ app/Config/App.php diupdate"

echo ""
echo "BaseURL sekarang: ${PROTOCOL}://${SERVER_IP}/"
echo ""
echo "Jika CSS masih tidak muncul:"
echo "  1. Clear cache browser (Ctrl+Shift+Delete)"
echo "  2. Hard reload (Ctrl+F5)"
echo "  3. Cek console browser (F12) untuk error"

