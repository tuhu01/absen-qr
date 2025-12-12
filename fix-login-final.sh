#!/bin/bash

# Script final untuk fix route login
# Jalankan dengan: bash fix-login-final.sh

echo "=== Fix Route Login - Final ==="
echo ""

cd "$(dirname "$0")"

# 1. Disable auto routing
echo "1. Disabling auto routing..."
sed -i "s|// \$routes->setAutoRoute(false);|\$routes->setAutoRoute(false);|g" app/Config/Routes.php
echo "✓ Auto routing disabled"
echo ""

# 2. Clear cache
echo "2. Clearing cache..."
find writable/cache -type f -delete 2>/dev/null
find writable/cache -type d -empty -delete 2>/dev/null
echo "✓ Cache cleared"
echo ""

# 3. Regenerate autoload
echo "3. Regenerating autoload..."
composer dump-autoload -q
echo "✓ Autoload regenerated"
echo ""

# 4. Show route login
echo "4. Route login di Routes.php:"
grep -A 2 "Auth Routes" app/Config/Routes.php | head -5
echo ""

# 5. Instructions
echo "=== LANGKAH WAJIB ==="
echo ""
echo "Jalankan perintah berikut untuk restart services:"
echo "  sudo systemctl restart php8.3-fpm nginx"
echo ""
echo "Setelah restart, test:"
echo "  curl http://192.168.100.151/login"
echo ""
echo "Seharusnya menampilkan form login, bukan halaman scan QR."
echo ""

