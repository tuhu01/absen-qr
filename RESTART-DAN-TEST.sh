#!/bin/bash

echo "=== Restart Services dan Test Route Login ==="
echo ""

echo "1. Restart PHP-FPM dan Nginx..."
echo "   Jalankan: sudo systemctl restart php8.3-fpm nginx"
echo ""

echo "2. Clear cache..."
rm -rf writable/cache/* 2>/dev/null
echo "   ✓ Cache cleared"
echo ""

echo "3. Test route login..."
sleep 2
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://172.16.11.102/login)
echo "   HTTP Code: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✓ Route /login bisa diakses"
    echo ""
    echo "4. Cek konten..."
    CONTENT=$(curl -s http://172.16.11.102/login 2>&1 | grep -i "login petugas\|username\|password" | head -1)
    if [ -n "$CONTENT" ]; then
        echo "   ✓ Form login ditemukan!"
        echo "   Content: $CONTENT"
    else
        echo "   ⚠ Halaman bisa diakses tapi mungkin bukan form login"
        echo "   Cek di browser: http://172.16.11.102/login"
    fi
else
    echo "   ✗ Route /login tidak bisa diakses (HTTP $HTTP_CODE)"
    echo "   Pastikan sudah restart services!"
fi

echo ""
echo "=== Selesai ==="

