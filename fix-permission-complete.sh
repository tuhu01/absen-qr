#!/bin/bash

# Script lengkap untuk fix permission denied error
# Jalankan dengan: sudo bash fix-permission-complete.sh

if [ "$EUID" -ne 0 ]; then 
    echo "Jalankan dengan: sudo bash fix-permission-complete.sh"
    exit 1
fi

set -e

echo "=== Fix Permission Denied Error ==="
echo ""

PROJECT_DIR="/home/tuhu-pangestu/college/absen-qr"

# 1. Fix permission folder parent (PENTING untuk traverse)
echo "1. Fix permission folder parent (agar www-data bisa traverse)..."
chmod 755 /home/tuhu-pangestu
chmod 755 /home/tuhu-pangestu/college
chmod 755 "$PROJECT_DIR"
echo "   ✓ Permission folder parent: 755"

# 2. Set ownership dan permission untuk folder public
echo ""
echo "2. Set ownership dan permission folder public..."
# Opsi 1: Ownership ke www-data (disarankan untuk production)
chown -R www-data:www-data "$PROJECT_DIR/public"
chmod -R 755 "$PROJECT_DIR/public"
chmod 644 "$PROJECT_DIR/public/index.php"
echo "   ✓ Folder public: owned by www-data, permission 755"

# 3. Set permission untuk folder writable
echo ""
echo "3. Set permission folder writable..."
chown -R www-data:www-data "$PROJECT_DIR/writable"
chmod -R 775 "$PROJECT_DIR/writable"
echo "   ✓ Folder writable: owned by www-data, permission 775"

# 4. Set permission untuk file penting
echo ""
echo "4. Set permission file penting..."
if [ -f "$PROJECT_DIR/.env" ]; then
    chmod 644 "$PROJECT_DIR/.env"
    echo "   ✓ .env: permission 644"
fi

# 5. Verifikasi permission
echo ""
echo "5. Verifikasi permission..."
echo "   Folder structure:"
ls -ld /home/tuhu-pangestu
ls -ld /home/tuhu-pangestu/college
ls -ld "$PROJECT_DIR"
ls -ld "$PROJECT_DIR/public"
echo ""
echo "   File index.php:"
ls -l "$PROJECT_DIR/public/index.php"

# 6. Test akses sebagai www-data
echo ""
echo "6. Test akses sebagai www-data..."
if sudo -u www-data test -r "$PROJECT_DIR/public/index.php"; then
    echo "   ✓ www-data bisa membaca index.php"
else
    echo "   ✗ www-data TIDAK bisa membaca index.php"
    echo "   Mencoba alternatif..."
    
    # Alternatif: Set permission lebih permisif (kurang aman tapi pasti bisa)
    chmod 755 "$PROJECT_DIR/public"
    chmod 644 "$PROJECT_DIR/public/index.php"
    chmod 755 /home/tuhu-pangestu
    chmod 755 /home/tuhu-pangestu/college
    chmod 755 "$PROJECT_DIR"
    
    if sudo -u www-data test -r "$PROJECT_DIR/public/index.php"; then
        echo "   ✓ Sekarang www-data bisa membaca index.php"
    else
        echo "   ✗ Masih tidak bisa. Cek SELinux atau AppArmor."
    fi
fi

if sudo -u www-data test -x "$PROJECT_DIR/public"; then
    echo "   ✓ www-data bisa akses folder public"
else
    echo "   ✗ www-data TIDAK bisa akses folder public"
fi

# 7. Restart nginx
echo ""
echo "7. Restart nginx..."
systemctl restart nginx
sleep 1

if systemctl is-active --quiet nginx; then
    echo "   ✓ Nginx berjalan"
else
    echo "   ✗ Nginx tidak berjalan"
    systemctl status nginx --no-pager -l | tail -5
fi

# 8. Test akses
echo ""
echo "8. Test akses file..."
if sudo -u www-data cat "$PROJECT_DIR/public/index.php" > /dev/null 2>&1; then
    echo "   ✓ www-data bisa membaca file"
else
    echo "   ✗ www-data masih tidak bisa membaca file"
fi

echo ""
echo "=== Selesai! ==="
echo ""
echo "Permission sudah diperbaiki."
echo ""
echo "Coba akses aplikasi:"
echo "  http://$(hostname -I | awk '{print $1}')"
echo ""
echo "Jika masih error, cek:"
echo "  1. sudo tail -f /var/log/nginx/absen-qr-error.log"
echo "  2. sudo systemctl status nginx"
echo "  3. Pastikan SELinux/AppArmor tidak memblokir"

