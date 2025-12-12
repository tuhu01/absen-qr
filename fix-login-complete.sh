#!/bin/bash

# Script lengkap untuk fix route login

echo "=== Fix Route Login ==="
echo ""

# 1. Fix permission cache
echo "1. Memperbaiki permission cache..."
sudo chown -R www-data:www-data writable/cache
sudo chmod -R 775 writable/cache
echo "✓ Cache permission fixed"
echo ""

# 2. Clear cache
echo "2. Membersihkan cache..."
rm -rf writable/cache/*
echo "✓ Cache cleared"
echo ""

# 3. Restart services
echo "3. Restart services..."
sudo systemctl restart php8.3-fpm nginx
echo "✓ Services restarted"
echo ""

# 4. Test route
echo "4. Testing route..."
php spark routes 2>&1 | grep -E "login|Login" | head -3
echo ""

echo "=== SELESAI ==="
echo ""
echo "Akses: http://192.168.100.151/login"
echo ""

