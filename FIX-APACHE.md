# Fix: Masih Muncul Halaman Default Apache2

## Masalah

Anda masih melihat halaman default Apache2 karena:
- Apache2 masih berjalan di port 80
- Nginx tidak bisa start karena port 80 sudah digunakan

## Solusi Cepat

Jalankan script untuk switch dari Apache2 ke Nginx:

```bash
sudo bash switch-to-nginx.sh
```

Script ini akan:
1. ✅ Stop dan disable Apache2
2. ✅ Install nginx (jika belum ada)
3. ✅ Setup konfigurasi nginx untuk aplikasi
4. ✅ Start nginx
5. ✅ Set permission folder

## Solusi Manual

Jika script tidak berjalan, lakukan manual:

### 1. Stop Apache2

```bash
sudo systemctl stop apache2
sudo systemctl disable apache2
```

### 2. Start Nginx

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 3. Verifikasi

```bash
# Cek nginx status
sudo systemctl status nginx

# Cek port 80
sudo ss -tlnp | grep :80
# atau
sudo netstat -tlnp | grep :80
```

### 4. Jika Nginx Belum Terinstall

Jalankan setup lengkap:
```bash
sudo bash setup-network.sh
```

## Troubleshooting

### Nginx Gagal Start

Jika nginx masih gagal start dengan error "Address already in use":

```bash
# Cek apa yang menggunakan port 80
sudo lsof -i :80
# atau
sudo fuser -k 80/tcp

# Lalu start nginx lagi
sudo systemctl start nginx
```

### Masih Melihat Halaman Default

1. **Clear cache browser** (Ctrl+Shift+Delete atau Ctrl+F5)
2. **Cek konfigurasi nginx:**
   ```bash
   sudo nginx -t
   sudo systemctl status nginx
   ```
3. **Cek log nginx:**
   ```bash
   sudo tail -f /var/log/nginx/absen-qr-error.log
   ```
4. **Test dari server:**
   ```bash
   curl http://localhost
   curl http://172.16.11.102
   ```

### Ingin Kembali ke Apache2

Jika ingin kembali menggunakan Apache2:

```bash
sudo systemctl stop nginx
sudo systemctl disable nginx
sudo systemctl start apache2
sudo systemctl enable apache2
```

## Setelah Fix

Setelah nginx berjalan, aplikasi dapat diakses di:
- **http://172.16.11.102**
- **http://localhost** (dari server)

