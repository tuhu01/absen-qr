#!/bin/bash

echo "=== Restart Services untuk Fix Login Route ==="
echo ""
echo "Jalankan script ini dengan sudo untuk restart PHP-FPM dan Nginx:"
echo ""
echo "sudo systemctl restart php8.1-fpm"
echo "sudo systemctl restart php8.2-fpm"
echo "sudo systemctl restart nginx"
echo ""
echo "Atau jalankan:"
echo "sudo bash RESTART-SERVICES.sh"
echo ""

if [ "$EUID" -eq 0 ]; then
    echo "Restarting services..."
    systemctl restart php8.1-fpm 2>/dev/null
    systemctl restart php8.2-fpm 2>/dev/null
    systemctl restart nginx
    echo "✓ Services restarted"
else
    echo "⚠ Script harus dijalankan dengan sudo"
    echo "Jalankan: sudo bash RESTART-SERVICES.sh"
fi

