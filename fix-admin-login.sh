#!/bin/bash

# Script untuk fix masalah /admin tidak redirect ke login
# Jalankan dengan: bash fix-admin-login.sh

echo "=== Fix Admin Login Redirect ==="
echo ""

cd "$(dirname "$0")"

# Cek apakah route login ada
echo "1. Cek route login..."
if php spark routes 2>&1 | grep -q "login"; then
    echo "   ✓ Route login terdaftar"
else
    echo "   ⚠ Route login mungkin tidak terdaftar"
fi

echo ""
echo "2. Verifikasi filter login..."
if grep -q "'admin/'" app/Config/Filters.php && grep -q "'admin/*'" app/Config/Filters.php; then
    echo "   ✓ Filter login aktif untuk admin/"
else
    echo "   ✗ Filter login tidak aktif untuk admin/"
fi

echo ""
echo "=== Solusi ==="
echo ""
echo "Jika /admin tidak redirect ke login, coba:"
echo ""
echo "1. Akses langsung halaman login:"
echo "   http://172.16.11.102/login"
echo ""
echo "2. Atau clear session dan coba lagi:"
echo "   - Clear browser cookies"
echo "   - Akses: http://172.16.11.102/admin"
echo ""
echo "3. Cek apakah sudah login:"
echo "   - Jika sudah login, akan langsung masuk dashboard"
echo "   - Jika belum login, seharusnya redirect ke /login"
echo ""
echo "4. Jika masih tidak redirect, cek:"
echo "   - app/Config/Filters.php (filter login harus aktif)"
echo "   - Route login harus terdaftar"

