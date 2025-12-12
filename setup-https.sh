#!/bin/bash

# Script untuk setup HTTPS dengan self-signed certificate
# Agar browser bisa akses kamera
# Jalankan dengan: sudo bash setup-https.sh

if [ "$EUID" -ne 0 ]; then 
    echo "Jalankan dengan: sudo bash setup-https.sh"
    exit 1
fi

echo "=== Setup HTTPS untuk Akses Kamera ==="
echo ""
echo "Browser memerlukan HTTPS untuk akses kamera (kecuali localhost)"
echo ""

cd "$(dirname "$0")"

SERVER_IP=$(hostname -I | awk '{print $1}')
SSL_DIR="/etc/nginx/ssl"
DOMAIN="absen-qr.local"

# 1. Buat direktori SSL
echo "1. Membuat direktori SSL..."
mkdir -p "$SSL_DIR"
echo "   ✓ Direktori SSL: $SSL_DIR"

# 2. Generate self-signed certificate
echo ""
echo "2. Generate self-signed certificate..."
if [ ! -f "$SSL_DIR/absen-qr.crt" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$SSL_DIR/absen-qr.key" \
        -out "$SSL_DIR/absen-qr.crt" \
        -subj "/C=ID/ST=Jakarta/L=Jakarta/O=AbsenQR/CN=$SERVER_IP" \
        2>/dev/null
    
    chmod 600 "$SSL_DIR/absen-qr.key"
    chmod 644 "$SSL_DIR/absen-qr.crt"
    echo "   ✓ Certificate dibuat"
else
    echo "   ✓ Certificate sudah ada"
fi

# 3. Buat konfigurasi nginx HTTPS
echo ""
echo "3. Membuat konfigurasi nginx HTTPS..."
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
PHP_SOCKET="/var/run/php/php${PHP_VERSION}-fpm.sock"

cat > /etc/nginx/sites-available/absen-qr-https << EOF
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name _;
    
    # SSL Configuration
    ssl_certificate $SSL_DIR/absen-qr.crt;
    ssl_certificate_key $SSL_DIR/absen-qr.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    # Document root
    root /home/tuhu-pangestu/college/absen-qr/public;
    index index.php index.html;

    # Log files
    access_log /var/log/nginx/absen-qr-https-access.log;
    error_log /var/log/nginx/absen-qr-https-error.log;

    # Ukuran upload maksimal
    client_max_body_size 20M;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Main location block
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    # PHP-FPM configuration
    location ~ \.php\$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:${PHP_SOCKET};
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
        include fastcgi_params;
        
        fastcgi_read_timeout 300;
        fastcgi_send_timeout 300;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Deny access to writable directory
    location ~ ^/(writable|app|tests|vendor|system|builds) {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|svg)\$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name _;
    return 301 https://\$host\$request_uri;
}
EOF

# 4. Enable site HTTPS
echo "4. Enable site HTTPS..."
ln -sf /etc/nginx/sites-available/absen-qr-https /etc/nginx/sites-enabled/

# 5. Test konfigurasi
echo "5. Test konfigurasi nginx..."
if nginx -t; then
    echo "   ✓ Konfigurasi valid"
else
    echo "   ✗ Konfigurasi tidak valid!"
    exit 1
fi

# 6. Restart nginx
echo "6. Restart nginx..."
systemctl restart nginx
echo "   ✓ Nginx di-restart"

# 7. Update baseURL
echo ""
echo "7. Update baseURL ke HTTPS..."
sed -i "s|app.baseURL = 'http://.*'|app.baseURL = 'https://${SERVER_IP}/'|g" .env
sed -i "s|public string \$baseURL = 'http://.*';|public string \$baseURL = 'https://${SERVER_IP}/';|g" app/Config/App.php
echo "   ✓ BaseURL diupdate ke HTTPS"

echo ""
echo "=== Selesai! ==="
echo ""
echo "HTTPS sudah diaktifkan!"
echo ""
echo "Akses aplikasi di:"
echo "  https://${SERVER_IP}"
echo ""
echo "⚠️  PERINGATAN:"
echo "  Browser akan menampilkan peringatan 'Not Secure' karena menggunakan"
echo "  self-signed certificate. Ini normal untuk development."
echo ""
echo "  Untuk mengakses:"
echo "  1. Klik 'Advanced' atau 'Lanjutkan'"
echo "  2. Klik 'Proceed to ${SERVER_IP} (unsafe)'"
echo ""
echo "  Setelah itu, browser akan bisa akses kamera."

