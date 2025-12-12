#!/bin/bash

# Script untuk memperbaiki GPG error dari WineHQ repository
# Jalankan dengan: sudo bash fix-gpg-error.sh

echo "=== Memperbaiki GPG Error WineHQ ==="
echo ""

if [ "$EUID" -ne 0 ]; then 
    echo "Script ini memerlukan akses root/sudo"
    echo "Jalankan dengan: sudo bash fix-gpg-error.sh"
    exit 1
fi

# Opsi 1: Tambahkan GPG key WineHQ
echo "1. Menambahkan GPG key WineHQ..."
wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - 2>/dev/null || {
    echo "   ⚠ Gagal menambahkan GPG key dengan apt-key (deprecated)"
    echo "   Mencoba metode alternatif..."
    
    # Metode alternatif untuk Ubuntu/Debian baru
    if command -v gpg &> /dev/null; then
        wget -qO - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /usr/share/keyrings/winehq-archive-keyring.gpg 2>/dev/null || {
            echo "   ⚠ Metode alternatif juga gagal"
        }
    fi
}

# Opsi 2: Nonaktifkan repository WineHQ jika tidak diperlukan
echo ""
echo "2. Mengecek repository WineHQ..."
WINE_REPO=$(find /etc/apt/sources.list.d/ -name "*wine*" 2>/dev/null | head -1)

if [ -n "$WINE_REPO" ]; then
    echo "   Repository WineHQ ditemukan: $WINE_REPO"
    read -p "   Nonaktifkan repository WineHQ? (y/n) [n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Comment out repository
        sed -i 's/^deb/#deb/g' "$WINE_REPO" 2>/dev/null
        sed -i 's/^deb-src/#deb-src/g' "$WINE_REPO" 2>/dev/null
        echo "   ✓ Repository WineHQ dinonaktifkan"
    else
        echo "   Repository WineHQ tetap aktif"
    fi
else
    echo "   Repository WineHQ tidak ditemukan di sources.list.d"
fi

# Opsi 3: Update dengan ignore errors
echo ""
echo "3. Testing apt update..."
apt update 2>&1 | grep -E "(NO_PUBKEY|error)" || echo "   ✓ Tidak ada error GPG"

echo ""
echo "=== Selesai ==="
echo ""
echo "Jika masih ada error, Anda bisa:"
echo "1. Nonaktifkan repository WineHQ secara manual"
echo "2. Atau jalankan: sudo apt update --allow-unauthenticated (tidak disarankan)"
echo ""
echo "Untuk setup aplikasi, error GPG WineHQ tidak akan mengganggu"
echo "karena kita tidak menginstall paket dari repository tersebut."

