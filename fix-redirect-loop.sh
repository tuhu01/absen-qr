#!/bin/bash

# Script untuk fix redirect loop error
# Jalankan dengan: sudo bash fix-redirect-loop.sh

echo "=== Fix Redirect Loop Error ==="
echo ""
echo "Masalah: forcehttps filter menyebabkan redirect loop"
echo "Solusi: Nonaktifkan forcehttps filter"
echo ""

cd "$(dirname "$0")"

# Backup file
cp app/Config/Filters.php app/Config/Filters.php.backup
echo "✓ Backup dibuat: app/Config/Filters.php.backup"

# Nonaktifkan forcehttps
sed -i "s/'forcehttps', \/\/ Force Global Secure Requests/\/\/ 'forcehttps', \/\/ Force Global Secure Requests - DISABLED untuk HTTP/g" app/Config/Filters.php

# Verifikasi
if grep -q "// 'forcehttps'" app/Config/Filters.php; then
    echo "✓ forcehttps filter sudah dinonaktifkan"
else
    echo "✗ Gagal menonaktifkan forcehttps filter"
    exit 1
fi

# Pastikan forceGlobalSecureRequests juga false
if grep -q "forceGlobalSecureRequests = true" app/Config/App.php; then
    sed -i "s/forceGlobalSecureRequests = true/forceGlobalSecureRequests = false/g" app/Config/App.php
    echo "✓ forceGlobalSecureRequests di-set ke false"
fi

echo ""
echo "=== Selesai! ==="
echo ""
echo "Perubahan:"
echo "  1. forcehttps filter dinonaktifkan"
echo "  2. forceGlobalSecureRequests = false"
echo ""
echo "Sekarang coba akses aplikasi lagi:"
echo "  http://$(hostname -I | awk '{print $1}')"
echo ""
echo "Jika masih error, clear cache browser (Ctrl+Shift+Delete)"

