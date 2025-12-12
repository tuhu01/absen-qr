#!/bin/bash

echo "=== Test Login Route ==="
echo ""

echo "1. Cek route login terdaftar:"
php spark routes 2>&1 | grep -i "login" || echo "   Route login tidak ditemukan"

echo ""
echo "2. Test akses /login:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://172.16.11.102/login)
echo "   HTTP Code: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✓ Route /login berhasil diakses"
    echo ""
    echo "3. Cek konten halaman:"
    curl -s http://172.16.11.102/login 2>&1 | grep -i "login\|username\|password" | head -3
else
    echo "   ✗ Route /login tidak bisa diakses (HTTP $HTTP_CODE)"
fi

echo ""
echo "=== Selesai ==="

