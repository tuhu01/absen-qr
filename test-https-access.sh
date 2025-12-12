#!/bin/bash

# Script untuk test akses HTTPS dan debug masalah
# Jalankan dengan: bash test-https-access.sh

SERVER_IP="172.16.11.102"

echo "=== Test Akses HTTPS ==="
echo ""

echo "1. Test akses utama..."
STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://${SERVER_IP})
echo "   Status: $STATUS"
if [ "$STATUS" = "200" ]; then
    echo "   ✓ Halaman utama bisa diakses"
else
    echo "   ✗ Halaman utama tidak bisa diakses"
fi

echo ""
echo "2. Test akses CSS..."
CSS_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://${SERVER_IP}/assets/css/material-dashboard.css)
echo "   Status: $CSS_STATUS"
if [ "$CSS_STATUS" = "200" ]; then
    echo "   ✓ CSS bisa diakses"
else
    echo "   ✗ CSS tidak bisa diakses"
fi

echo ""
echo "3. Test akses JS..."
JS_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://${SERVER_IP}/assets/js/core/jquery-3.5.1.min.js)
echo "   Status: $JS_STATUS"
if [ "$JS_STATUS" = "200" ]; then
    echo "   ✓ JS bisa diakses"
else
    echo "   ✗ JS tidak bisa diakses"
fi

echo ""
echo "4. Cek baseURL di HTML..."
BASE_URL=$(curl -k -s https://${SERVER_IP} | grep -o "baseURL: '[^']*'" | head -1)
echo "   BaseURL di HTML: $BASE_URL"

echo ""
echo "5. Cek link CSS di HTML..."
CSS_LINKS=$(curl -k -s https://${SERVER_IP} | grep -o 'href="[^"]*\.css[^"]*"' | head -3)
echo "   CSS links:"
echo "$CSS_LINKS" | sed 's/^/     /'

echo ""
echo "=== Kesimpulan ==="
if [ "$STATUS" = "200" ] && [ "$CSS_STATUS" = "200" ]; then
    echo "✓ Server HTTPS berjalan dengan baik"
    echo "✓ Assets bisa diakses"
    echo ""
    echo "Masalahnya kemungkinan di browser:"
    echo "  1. Certificate belum di-accept"
    echo "  2. Browser cache"
    echo "  3. Mixed content blocking"
    echo ""
    echo "Solusi:"
    echo "  - Accept certificate di browser"
    echo "  - Clear cache (Ctrl+Shift+Delete)"
    echo "  - Hard reload (Ctrl+F5)"
else
    echo "✗ Ada masalah dengan konfigurasi HTTPS"
    echo "  Jalankan: sudo bash fix-https-issues.sh"
fi

