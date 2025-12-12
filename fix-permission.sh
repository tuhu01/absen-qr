#!/bin/bash

# Script untuk fix permission issue - www-data tidak bisa akses folder
# Jalankan dengan: sudo bash fix-permission.sh

if [ "$EUID" -ne 0 ]; then 
    echo "Jalankan dengan: sudo bash fix-permission.sh"
    exit 1
fi

echo "=== Fix Permission Issue ==="
echo ""
echo "Masalah: www-data tidak bisa akses folder aplikasi"
echo "Solusi: Set permission dan ownership yang benar"
echo ""

PROJECT_DIR="/home/tuhu-pangestu/college/absen-qr"

# 1. Set permission untuk folder parent (agar www-data bisa traverse)
echo "1. Set permission folder parent..."
chmod 755 /home/tuhu-pangestu
chmod 755 /home/tuhu-pangestu/college
chmod 755 "$PROJECT_DIR"
echo "   ✓ Permission folder parent diupdate"

# 2. Set ownership dan permission untuk folder public
echo "2. Set permission folder public..."
chown -R www-data:www-data "$PROJECT_DIR/public"
chmod -R 755 "$PROJECT_DIR/public"
chmod 644 "$PROJECT_DIR/public/index.php"
echo "   ✓ Permission folder public diupdate"

# 3. Set permission untuk folder writable
echo "3. Set permission folder writable..."
chown -R www-data:www-data "$PROJECT_DIR/writable"
chmod -R 775 "$PROJECT_DIR/writable"
echo "   ✓ Permission folder writable diupdate"

# 4. Set permission untuk file .env (www-data perlu baca)
echo "4. Set permission file .env..."
if [ -f "$PROJECT_DIR/.env" ]; then
    chmod 644 "$PROJECT_DIR/.env"
    echo "   ✓ Permission .env diupdate"
fi

# 5. Verifikasi
echo ""
echo "5. Verifikasi permission..."
echo "   Folder public:"
ls -ld "$PROJECT_DIR/public"
echo "   File index.php:"
ls -l "$PROJECT_DIR/public/index.php"

# 6. Test akses sebagai www-data
echo ""
echo "6. Test akses sebagai www-data..."
if sudo -u www-data test -r "$PROJECT_DIR/public/index.php"; then
    echo "   ✓ www-data bisa membaca index.php"
else
    echo "   ✗ www-data TIDAK bisa membaca index.php"
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
echo "   ✓ Nginx di-restart"

echo ""
echo "=== Selesai! ==="
echo ""
echo "Permission sudah diperbaiki. Coba akses aplikasi lagi:"
echo "  http://$(hostname -I | awk '{print $1}')"
echo ""
echo "Jika masih error, cek log:"
echo "  sudo tail -f /var/log/nginx/absen-qr-error.log"

