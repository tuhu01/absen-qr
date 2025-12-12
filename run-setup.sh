#!/bin/bash

# Wrapper script untuk menjalankan setup lengkap
# Script ini akan meminta password sudo saat diperlukan

echo "=== Setup Lengkap Aplikasi Absen QR ==="
echo ""
echo "Script ini akan:"
echo "1. Memperbaiki error GPG WineHQ"
echo "2. Setup database dan migration"
echo "3. Install dan konfigurasi nginx"
echo "4. Setup agar bisa diakses dari komputer lain"
echo ""
read -p "Tekan Enter untuk melanjutkan atau Ctrl+C untuk membatalkan..."

# Langkah 1: Fix GPG error
echo ""
echo "=== Langkah 1: Memperbaiki Error GPG ==="
sudo bash fix-apt-repo.sh

# Langkah 2: Setup lengkap
echo ""
echo "=== Langkah 2: Setup Lengkap ==="
sudo bash setup-network.sh

echo ""
echo "=== Setup Selesai! ==="
echo ""
echo "Aplikasi dapat diakses di:"
echo "  http://$(hostname -I | awk '{print $1}')"
echo ""
echo "Dari komputer lain di network yang sama."

