# Solusi: Cannot Access Camera di Halaman Absen Masuk

## Masalah
Browser menampilkan error **"Cannot access camera"** di halaman absen masuk.

## Penyebab
Browser modern memblokir akses kamera dari **HTTP** (kecuali localhost):
- Aplikasi berjalan di **HTTP** (`http://192.168.137.159`)
- API `getUserMedia()` memerlukan **HTTPS** untuk akses kamera dari IP address
- Browser security policy: HTTP dengan IP → **TIDAK bisa** akses kamera

## Solusi

### Opsi 1: Setup HTTPS (Disarankan)

Jalankan script untuk setup HTTPS dengan self-signed certificate:

```bash
cd /home/tuhu-pangestu/college/absen-qr
sudo bash setup-https.sh
```

Script ini akan:
1. Generate self-signed SSL certificate
2. Setup nginx untuk HTTPS (port 443)
3. Redirect HTTP ke HTTPS
4. Update baseURL ke HTTPS

**Setelah setup:**
- Akses aplikasi di: `https://192.168.137.159`
- Browser akan menampilkan peringatan "Not Secure" (normal untuk self-signed)
- Klik **"Advanced"** → **"Proceed to 192.168.137.159 (unsafe)"**
- Setelah itu kamera bisa diakses

### Opsi 2: Akses via localhost (Alternatif)

Jika hanya untuk testing di server sendiri:

1. Edit `/etc/hosts` di komputer server:
   ```bash
   sudo nano /etc/hosts
   ```
   Tambahkan:
   ```
   127.0.0.1 absen-qr.local
   ```

2. Akses via: `http://absen-qr.local` atau `http://localhost`

### Opsi 3: Gunakan IP localhost (Quick Fix)

Akses via: `http://127.0.0.1` atau `http://localhost` dari server sendiri

## Penjelasan

Browser security policy:
- ✅ **HTTPS** → Bisa akses kamera
- ✅ **localhost** → Bisa akses kamera  
- ✅ **127.0.0.1** → Bisa akses kamera
- ❌ **HTTP dengan IP** → **TIDAK bisa** akses kamera

## Setelah Setup HTTPS

1. **Akses aplikasi:** `https://192.168.137.159`
2. **Accept certificate warning** di browser
3. **Berikan permission kamera** saat browser meminta
4. **Kamera seharusnya sudah bisa digunakan**

## Troubleshooting

### Browser masih memblokir kamera

1. **Cek permission kamera di browser:**
   - Chrome: `chrome://settings/content/camera`
   - Firefox: `about:preferences#privacy` → Permissions → Camera

2. **Clear cache dan reload:**
   - Ctrl+Shift+Delete → Clear cache
   - Reload halaman (Ctrl+F5)

3. **Cek console browser:**
   - F12 → Console
   - Lihat error message

### Setelah setup HTTPS, CSS tidak ter-load

1. **Accept certificate terlebih dahulu**
2. **Clear browser cache**
3. **Hard reload:** Ctrl+F5

## Catatan

- **HTTPS dengan self-signed certificate** adalah normal untuk development
- Browser akan menampilkan warning, tapi aman untuk digunakan
- Untuk production, gunakan certificate dari Let's Encrypt atau CA lainnya
