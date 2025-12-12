#!/bin/bash

# Script untuk fix login filter yang menyebabkan redirect loop
# Jalankan dengan: bash fix-login-filter.sh

echo "=== Fix Login Filter Redirect Loop ==="
echo ""

cd "$(dirname "$0")"

# Backup
cp app/Config/Filters.php app/Config/Filters.php.backup2
echo "✓ Backup dibuat"

# Nonaktifkan login filter dari globals
sed -i "s/'login'/\/\/ 'login' \/\/ DISABLED - hanya untuk route tertentu/g" app/Config/Filters.php

echo "✓ Login filter dinonaktifkan dari globals"
echo ""
echo "Login filter sekarang hanya aktif untuk route:"
echo "  - admin/"
echo "  - admin/*"
echo "  - register/"
echo ""
echo "Route lain (seperti /) tidak memerlukan login"
echo ""
echo "Coba akses aplikasi lagi:"
echo "  http://$(hostname -I | awk '{print $1}')"

