# Cara Update IP Setelah Pindah WiFi

## Yang Sudah Diupdate
✅ **baseURL** di `app/Config/App.php` sudah diupdate ke: `http://192.168.100.151/`

## Langkah Selanjutnya

### 1. Update .env (jika ada)
Jika file `.env` ada, update manual:
```bash
nano .env
```

Cari baris:
```
app.baseURL = 'https://172.16.11.102/'
```

Ubah menjadi:
```
app.baseURL = 'http://192.168.100.151/'
```

### 2. Restart Services (WAJIB!)
```bash
sudo systemctl restart php8.3-fpm nginx
```

### 3. Clear Cache
```bash
rm -rf writable/cache/*
```

## Atau Gunakan Script Otomatis

Jalankan script yang sudah dibuat:
```bash
./update-ip.sh
```

Script ini akan:
- Otomatis deteksi IP baru
- Update baseURL di `app/Config/App.php` dan `.env`
- Clear cache
- Restart services

## Akses Aplikasi

Setelah restart, akses aplikasi di:
- **HTTP**: http://192.168.100.151/
- **Login**: http://192.168.100.151/login

## Catatan

- Jika menggunakan **HTTPS**, pastikan sertifikat SSL masih valid
- Jika IP berubah lagi, jalankan `./update-ip.sh` lagi
- Nginx sudah dikonfigurasi untuk menerima request dari IP manapun (`server_name _`), jadi tidak perlu update konfigurasi Nginx

## Troubleshooting

Jika masih tidak bisa diakses:
1. Cek IP dengan: `hostname -I`
2. Pastikan firewall mengizinkan port 80/443
3. Cek log: `sudo tail -50 /var/log/nginx/error.log`
4. Test dari komputer lain di jaringan yang sama

