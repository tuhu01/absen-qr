                                                                                                                                                                                                                                                                                                                                                                #!/bin/bash

# Script untuk nonaktifkan HTTPS dan kembali ke HTTP
# Dengan workaround untuk kamera
# Jalankan dengan: sudo bash disable-https-back-to-http.sh

if [ "$EUID" -ne 0 ]; then 
    echo "Jalankan dengan: sudo bash disable-https-back-to-http.sh"
    exit 1
fi

echo "=== Nonaktifkan HTTPS, Kembali ke HTTP ==="
echo ""
echo "Ini akan:"
echo "  1. Nonaktifkan HTTPS"
echo "  2. Aktifkan HTTP"
echo "  3. Update baseURL ke HTTP"
echo "  4. CSS akan ter-load dengan baik"
echo ""
echo "Catatan: Kamera tidak akan bisa diakses dari komputer lain"
echo "         (kecuali via localhost)"
echo ""

cd "$(dirname "$0")"

SERVER_IP=$(hostname -I | awk '{print $1}')

# 1. Nonaktifkan HTTPS config
echo "1. Nonaktifkan konfigurasi HTTPS..."
if [ -L /etc/nginx/sites-enabled/absen-qr-https ]; then
    rm /etc/nginx/sites-enabled/absen-qr-https
    echo "   ✓ HTTPS dinonaktifkan"
fi

# 2. Aktifkan HTTP config
echo "2. Aktifkan konfigurasi HTTP..."
if [ ! -L /etc/nginx/sites-enabled/absen-qr ]; then
    ln -sf /etc/nginx/sites-available/absen-qr /etc/nginx/sites-enabled/
    echo "   ✓ HTTP diaktifkan"
fi

# 3. Update baseURL ke HTTP
echo "3. Update baseURL ke HTTP..."
sed -i "s|app.baseURL = '.*'|app.baseURL = 'http://${SERVER_IP}/'|g" .env
sed -i "s|public string \$baseURL = '.*';|public string \$baseURL = 'http://${SERVER_IP}/';|g" app/Config/App.php
echo "   ✓ BaseURL: http://${SERVER_IP}/"

# 4. Test dan reload nginx
echo "4. Test dan reload nginx..."
if nginx -t 2>/dev/null; then
    systemctl reload nginx
    echo "   ✓ Nginx di-reload"
else
    echo "   ✗ Konfigurasi error"
    nginx -t
    exit 1
fi

# 5. Test akses
echo "5. Test akses..."
sleep 1
if curl -s -o /dev/null -w "%{http_code}" http://${SERVER_IP} | grep -q "200"; then
    echo "   ✓ HTTP berjalan"
else
    echo "   ✗ HTTP tidak berjalan"
fi

echo ""
echo "=== Selesai! ==="
echo ""
echo "Aplikasi sekarang menggunakan HTTP:"
echo "  http://${SERVER_IP}"
echo ""
echo "✅ CSS akan ter-load dengan baik"
echo "✅ Tidak ada certificate warning"
echo ""
echo "⚠️  KAMERA:"
echo "   Kamera TIDAK bisa diakses dari komputer lain (browser policy)"
echo ""
echo "   Opsi untuk kamera:"
echo "   1. Akses via localhost dari server: http://localhost"
echo "   2. Setup HTTPS dengan certificate yang benar (Let's Encrypt)"
echo "   3. Gunakan aplikasi mobile yang support HTTP untuk kamera"

