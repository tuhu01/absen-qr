#!/bin/bash

echo "=== Fix Login Route - Complete ==="
echo ""

cd "$(dirname "$0")"

echo "1. Clear cache..."
rm -rf writable/cache/* 2>/dev/null
echo "   ✓ Cache cleared"

echo ""
echo "2. Cek route login di Routes.php..."
if grep -q "login.*AuthController" app/Config/Routes.php; then
    echo "   ✓ Route login ditemukan di Routes.php"
else
    echo "   ✗ Route login TIDAK ditemukan di Routes.php"
fi

echo ""
echo "3. Cek AuthController..."
if [ -f "vendor/myth/auth/src/Controllers/AuthController.php" ]; then
    echo "   ✓ AuthController.php exists"
else
    echo "   ✗ AuthController.php NOT found"
fi

echo ""
echo "4. Test akses /login..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://172.16.11.102/login)
echo "   HTTP Code: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✓ Route /login bisa diakses"
    echo ""
    echo "5. Cek konten halaman..."
    CONTENT=$(curl -s http://172.16.11.102/login 2>&1 | grep -i "login petugas\|username\|password" | head -1)
    if [ -n "$CONTENT" ]; then
        echo "   ✓ Halaman login ditemukan"
        echo "   Content: $CONTENT"
    else
        echo "   ✗ Halaman login TIDAK ditemukan (mungkin masih halaman scan)"
        echo ""
        echo "   SOLUSI:"
        echo "   1. Restart PHP-FPM: sudo systemctl restart php8.1-fpm"
        echo "   2. Restart Nginx: sudo systemctl restart nginx"
        echo "   3. Clear browser cache dan cookies"
        echo "   4. Coba akses lagi: http://172.16.11.102/login"
    fi
else
    echo "   ✗ Route /login tidak bisa diakses (HTTP $HTTP_CODE)"
fi

echo ""
echo "=== Selesai ==="

