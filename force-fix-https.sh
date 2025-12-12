#!/bin/bash

# Script untuk force fix masalah HTTPS
# Jalankan dengan: sudo bash force-fix-https.sh

if [ "$EUID" -ne 0 ]; then 
    echo "Jalankan dengan: sudo bash force-fix-https.sh"
    exit 1
fi

echo "=== Force Fix HTTPS Issues ==="
echo ""

cd "$(dirname "$0")"

SERVER_IP=$(hostname -I | awk '{print $1}')

# 1. Pastikan baseURL benar
echo "1. Fix baseURL..."
sed -i "s|app.baseURL = '.*'|app.baseURL = 'https://${SERVER_IP}/'|g" .env
sed -i "s|public string \$baseURL = '.*';|public string \$baseURL = 'https://${SERVER_IP}/';|g" app/Config/App.php
echo "   ✓ BaseURL: https://${SERVER_IP}/"

# 2. Pastikan konfigurasi HTTPS aktif
echo "2. Enable konfigurasi HTTPS..."
ln -sf /etc/nginx/sites-available/absen-qr-https /etc/nginx/sites-enabled/ 2>/dev/null
if [ -f /etc/nginx/sites-enabled/absen-qr ] && [ ! -L /etc/nginx/sites-enabled/absen-qr-https ]; then
    rm /etc/nginx/sites-enabled/absen-qr
fi
echo "   ✓ Konfigurasi HTTPS aktif"

# 3. Test dan reload nginx
echo "3. Test dan reload nginx..."
if nginx -t 2>/dev/null; then
    systemctl reload nginx
    echo "   ✓ Nginx di-reload"
else
    echo "   ✗ Konfigurasi nginx error"
    nginx -t
    exit 1
fi

# 4. Set permission assets
echo "4. Set permission assets..."
chmod -R 755 /home/tuhu-pangestu/college/absen-qr/public/assets
chown -R www-data:www-data /home/tuhu-pangestu/college/absen-qr/public/assets
echo "   ✓ Permission assets diupdate"

# 5. Test akses
echo "5. Test akses..."
sleep 1
if curl -k -s -o /dev/null -w "%{http_code}" https://${SERVER_IP} | grep -q "200"; then
    echo "   ✓ HTTPS berjalan"
else
    echo "   ✗ HTTPS tidak berjalan"
fi

echo ""
echo "=== Selesai! ==="
echo ""
echo "INSTRUKSI PENTING:"
echo ""
echo "1. Buka browser dan akses: https://${SERVER_IP}"
echo ""
echo "2. Browser akan menampilkan WARNING (ini NORMAL):"
echo "   'Your connection is not private'"
echo ""
echo "3. Klik 'Advanced' atau 'Show Details'"
echo ""
echo "4. Klik 'Proceed to ${SERVER_IP} (unsafe)' atau 'Continue'"
echo "   (JANGAN klik 'Go back' atau 'Back to safety')"
echo ""
echo "5. Setelah accept certificate:"
echo "   - Halaman akan reload"
echo "   - CSS seharusnya sudah muncul"
echo "   - Browser akan minta permission kamera"
echo ""
echo "6. Klik 'Allow' untuk permission kamera"
echo ""
echo "7. Jika CSS masih tidak muncul:"
echo "   - Tekan Ctrl+Shift+Delete"
echo "   - Pilih 'Cached images and files'"
echo "   - Clear data"
echo "   - Tekan Ctrl+F5 untuk hard reload"
echo ""
echo "PENTING: Certificate warning HARUS di-accept dulu!"
echo "Browser akan memblokir SEMUA resources sampai certificate di-accept."

