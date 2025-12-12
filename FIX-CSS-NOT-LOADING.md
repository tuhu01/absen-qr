# Fix: CSS Tidak Ter-load (Tampilan Tidak Ada Style)

## Masalah

CSS dan assets tidak ter-load, tampilan seperti tidak ada style-nya.

## Penyebab

1. **BaseURL tidak sesuai dengan protokol yang digunakan**
   - BaseURL di-set ke HTTPS tapi akses via HTTP
   - Atau sebaliknya
   - Browser memblokir mixed content (HTTP page dengan HTTPS assets)

2. **HTTPS belum di-setup**
   - BaseURL sudah di-set ke HTTPS
   - Tapi HTTPS belum dikonfigurasi di nginx

## Solusi

### Opsi 1: Fix BaseURL (Cepat)

Jalankan script untuk update baseURL sesuai protokol yang aktif:

```bash
bash fix-baseurl.sh
```

Script akan:
- Deteksi apakah HTTPS aktif atau tidak
- Update baseURL ke protokol yang sesuai
- Update `.env` dan `app/Config/App.php`

### Opsi 2: Setup HTTPS (Disarankan)

Jika ingin menggunakan HTTPS (untuk akses kamera juga):

```bash
sudo bash setup-https.sh
```

Setelah itu:
- Akses via: `https://172.16.11.102`
- BaseURL akan otomatis di-update ke HTTPS

### Opsi 3: Manual Fix

Edit file `.env`:
```bash
nano .env
```

Ubah:
```
app.baseURL = 'http://172.16.11.102/'
```

Edit `app/Config/App.php`:
```bash
nano app/Config/App.php
```

Ubah line 24:
```php
public string $baseURL = 'http://172.16.11.102/';
```

## Setelah Fix

1. **Clear cache browser:**
   - Ctrl+Shift+Delete
   - Pilih "Cached images and files"
   - Clear

2. **Hard reload:**
   - Ctrl+F5 atau Shift+F5

3. **Cek console browser:**
   - F12 → Console
   - Lihat apakah ada error loading assets

## Verifikasi

Cek apakah assets bisa diakses:
```bash
curl -I http://172.16.11.102/assets/css/material-dashboard.css
```

Jika return 200 OK, berarti assets bisa diakses.

## Troubleshooting

### CSS masih tidak muncul

1. **Cek baseURL di source HTML:**
   - View page source (Ctrl+U)
   - Cari link CSS, pastikan URL-nya benar

2. **Cek console browser:**
   - F12 → Console
   - Lihat error message

3. **Cek Network tab:**
   - F12 → Network
   - Reload page
   - Lihat apakah CSS file return 404 atau error lain

### Mixed Content Error

Jika ada error "Mixed Content":
- Pastikan baseURL menggunakan protokol yang sama dengan URL yang diakses
- HTTP → baseURL harus HTTP
- HTTPS → baseURL harus HTTPS

