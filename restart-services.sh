#!/bin/bash

echo "=== Restart PHP-FPM dan Nginx ==="
echo ""

# Restart PHP 8.3 FPM
echo "1. Restarting PHP 8.3 FPM..."
sudo systemctl restart php8.3-fpm
if [ $? -eq 0 ]; then
    echo "   ✓ PHP 8.3 FPM restarted"
else
    echo "   ✗ Failed to restart PHP 8.3 FPM"
    echo "   Coba: sudo systemctl restart php8.3-fpm"
fi

echo ""
echo "2. Restarting Nginx..."
sudo systemctl restart nginx
if [ $? -eq 0 ]; then
    echo "   ✓ Nginx restarted"
else
    echo "   ✗ Failed to restart Nginx"
    echo "   Coba: sudo systemctl restart nginx"
fi

echo ""
echo "3. Checking status..."
echo ""
echo "PHP-FPM Status:"
sudo systemctl status php8.3-fpm --no-pager | head -3

echo ""
echo "Nginx Status:"
sudo systemctl status nginx --no-pager | head -3

echo ""
echo "=== Selesai ==="
echo ""
echo "Sekarang coba akses: http://172.16.11.102/login"
echo "Seharusnya menampilkan form login."

