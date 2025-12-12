#!/bin/bash

echo "=== Restart Services Manual ==="
echo ""
echo "Jika tidak bisa restart dengan systemctl, coba cara berikut:"
echo ""

# Cek PHP-FPM version
PHP_VERSION=$(php -v | head -1 | grep -oP '\d+\.\d+' | head -1)
echo "PHP Version: $PHP_VERSION"

# Cek service yang tersedia
echo ""
echo "Services yang tersedia:"
systemctl list-units --type=service 2>/dev/null | grep -E "php|nginx" | head -5

echo ""
echo "=== Cara Restart Manual ==="
echo ""
echo "1. Restart PHP-FPM:"
echo "   sudo systemctl restart php${PHP_VERSION}-fpm"
echo "   atau"
echo "   sudo service php${PHP_VERSION}-fpm restart"
echo ""
echo "2. Restart Nginx:"
echo "   sudo systemctl restart nginx"
echo "   atau"
echo "   sudo service nginx restart"
echo ""
echo "3. Atau restart semua sekaligus:"
echo "   sudo systemctl restart php${PHP_VERSION}-fpm nginx"
echo ""
echo "4. Cek status:"
echo "   sudo systemctl status php${PHP_VERSION}-fpm"
echo "   sudo systemctl status nginx"
echo ""

