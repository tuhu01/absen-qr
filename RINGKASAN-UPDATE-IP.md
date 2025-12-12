# Ringkasan Update IP

## IP Baru
**192.168.100.151**

## Yang Sudah Diupdate
✅ `app/Config/App.php` → baseURL = `http://192.168.100.151/`

## Yang Perlu Dilakukan

### 1. Restart Services (WAJIB!)
```bash
sudo systemctl restart php8.3-fpm nginx
```

### 2. Update .env (jika ada)
Edit file `.env` dan ubah:
```
app.baseURL = 'http://192.168.100.151/'
```

### 3. Clear Cache
```bash
rm -rf writable/cache/*
```

## Akses Aplikasi
http://192.168.100.151/

## Script Otomatis
Jalankan `./update-ip.sh` untuk update otomatis di masa depan.

