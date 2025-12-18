# Setup Auto-Pull untuk Server 2 (Cron Job Polling)

## Pendahuluan
Instruksi ini untuk setup auto-pull kode dari GitHub ke server 2 menggunakan cron job yang mengecek setiap 1 menit. Setiap kali ada perubahan di branch `main` GitHub, server 2 akan otomatis pull perubahan.

## Prasyarat
- Server 2 memiliki akses internet
- Git sudah terinstall di server 2
- Repo sudah di-clone di `/var/www/absen-qr`
- User memiliki permission untuk menjalankan git dan cron

## Langkah 1: Clone Repo (Jika Belum Ada)
Jika repo belum ada di server 2, clone dulu:
```bash
cd /var/www
sudo git clone https://github.com/tuhu01/absen-qr.git
sudo chown -R $USER:$USER /var/www/absen-qr
```

## Langkah 2: Buat Script Auto-Pull
Buat file script `/home/$USER/auto-pull.sh`:
```bash
#!/bin/bash

# Script untuk auto-pull dari GitHub setiap kali dijalankan
REPO_PATH="/var/www/absen-qr"
cd "$REPO_PATH" || exit 1

# Fetch latest dari remote
git fetch origin

# Cek apakah ada perubahan
LOCAL_COMMIT=$(git rev-parse HEAD)
REMOTE_COMMIT=$(git rev-parse origin/main)

if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
    echo "$(date): Ada perubahan, pulling..."
    git pull origin main
    # Opsional: Restart services jika perlu
    # sudo systemctl restart nginx php8.3-fpm
else
    echo "$(date): Tidak ada perubahan."
fi
```

Buat executable:
```bash
chmod +x /home/$USER/auto-pull.sh
```

## Langkah 3: Setup Cron Job
Edit crontab untuk menjalankan script setiap 1 menit:
```bash
crontab -e
```

Tambahkan baris ini di akhir file:
```
* * * * * /home/$USER/auto-pull.sh >> /home/$USER/auto-pull.log 2>&1
```

Simpan dan exit (biasanya Ctrl+X, Y, Enter).

## Langkah 4: Test Setup
1. Jalankan script manual:
   ```bash
   /home/$USER/auto-pull.sh
   ```

2. Cek log:
   ```bash
   tail -f /home/$USER/auto-pull.log
   ```

3. Push perubahan ke GitHub dari server 1, tunggu 1-2 menit, lalu cek apakah server 2 terupdate.

## Troubleshooting
- **Cron tidak jalan**: Cek `systemctl status cron` atau `service cron status`
- **Permission denied**: Pastikan user memiliki akses ke `/var/www/absen-qr` dan git
- **Git error**: Pastikan repo sudah di-clone dengan benar dan remote origin sudah benar
- **Log kosong**: Cek apakah cron job tersimpan dengan `crontab -l`

## Catatan
- Delay maksimal 1 menit untuk update
- Jika ingin frekuensi berbeda, ubah cron expression (contoh: `*/5 * * * *` untuk setiap 5 menit)
- Untuk monitoring, cek log secara berkala
