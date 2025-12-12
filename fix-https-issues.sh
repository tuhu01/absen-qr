#!/bin/bash

# Script untuk fix masalah setelah setup HTTPS
# Jalankan dengan: sudo bash fix-https-issues.sh

if [ "$EUID" -ne 0 ]; then 
    echo "Jalankan dengan: sudo bash fix-https-issues.sh"
    exit 1
fi

echo "=== Fix Masalah HTTPS (CSS & Kamera) ==="
echo ""

cd "$(dirname "$0")"

SERVER_IP=$(hostname -I | awk '{print $1}')

# 1. Verifikasi HTTPS berjalan
echo "1. Verifikasi HTTPS..."
if curl -k -s -o /dev/null -w "%{http_code}" https://${SERVER_IP} | grep -q "200\|301\|302"; then
    echo "   ✓ HTTPS berjalan"
else
    echo "   ✗ HTTPS tidak berjalan, setup ulang..."
    bash setup-https.sh
    exit 0
fi

# 2. Cek certificate
echo "2. Cek SSL certificate..."
if [ -f /etc/nginx/ssl/absen-qr.crt ] && [ -f /etc/nginx/ssl/absen-qr.key ]; then
    echo "   ✓ Certificate ada"
else
    echo "   ✗ Certificate tidak ada, generate ulang..."
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/absen-qr.key \
        -out /etc/nginx/ssl/absen-qr.crt \
        -subj "/C=ID/ST=Jakarta/L=Jakarta/O=AbsenQR/CN=${SERVER_IP}" \
        2>/dev/null
    chmod 600 /etc/nginx/ssl/absen-qr.key
    chmod 644 /etc/nginx/ssl/absen-qr.crt
    systemctl reload nginx
fi

# 3. Pastikan baseURL benar
echo "3. Verifikasi baseURL..."
if grep -q "https://${SERVER_IP}/" .env && grep -q "https://${SERVER_IP}/" app/Config/App.php; then
    echo "   ✓ BaseURL sudah benar (HTTPS)"
else
    echo "   ⚠ Update baseURL ke HTTPS..."
    sed -i "s|app.baseURL = '.*'|app.baseURL = 'https://${SERVER_IP}/'|g" .env
    sed -i "s|public string \$baseURL = '.*';|public string \$baseURL = 'https://${SERVER_IP}/';|g" app/Config/App.php
    echo "   ✓ BaseURL diupdate"
fi

# 4. Test akses assets
echo "4. Test akses assets..."
if curl -k -s -o /dev/null -w "%{http_code}" https://${SERVER_IP}/assets/css/material-dashboard.css | grep -q "200"; then
    echo "   ✓ CSS bisa diakses"
else
    echo "   ✗ CSS tidak bisa diakses"
fi

# 5. Pastikan konfigurasi nginx benar
echo "5. Verifikasi konfigurasi nginx..."
if [ -f /etc/nginx/sites-enabled/absen-qr-https ]; then
    echo "   ✓ Konfigurasi HTTPS aktif"
else
    echo "   ⚠ Konfigurasi HTTPS tidak aktif, enable..."
    ln -sf /etc/nginx/sites-available/absen-qr-https /etc/nginx/sites-enabled/
    nginx -t && systemctl reload nginx
fi

# 6. Disable konfigurasi HTTP lama jika ada
if [ -f /etc/nginx/sites-enabled/absen-qr ] && [ ! -L /etc/nginx/sites-enabled/absen-qr-https ]; then
    echo "6. Menonaktifkan konfigurasi HTTP lama..."
    rm /etc/nginx/sites-enabled/absen-qr
    echo "   ✓ Konfigurasi HTTP dinonaktifkan"
fi

echo ""
echo "=== Selesai! ==="
echo ""
echo "INSTRUKSI UNTUK BROWSER:"
echo ""
echo "1. Akses: https://${SERVER_IP}"
echo ""
echo "2. Browser akan menampilkan peringatan 'Your connection is not private'"
echo "   Ini NORMAL untuk self-signed certificate"
echo ""
echo "3. Klik 'Advanced' atau 'Lanjutkan'"
echo ""
echo "4. Klik 'Proceed to ${SERVER_IP} (unsafe)' atau 'Continue to site'"
echo ""
echo "5. Setelah itu:"
echo "   - CSS seharusnya sudah muncul"
echo "   - Browser akan minta permission kamera (Allow)"
echo "   - Kamera seharusnya sudah bisa digunakan"
echo ""
echo "6. Jika CSS masih tidak muncul:"
echo "   - Clear cache browser (Ctrl+Shift+Delete)"
echo "   - Hard reload (Ctrl+F5)"
echo "   - Cek console browser (F12) untuk error"
echo ""
echo "7. Jika kamera masih tidak bisa:"
echo "   - Cek permission kamera di browser settings"
echo "   - Pastikan sudah accept certificate"
echo "   - Cek console browser (F12) untuk error"

