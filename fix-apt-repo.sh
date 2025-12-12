#!/bin/bash

# Script cepat untuk memperbaiki error GPG WineHQ
# Opsi: Nonaktifkan repository WineHQ (tidak diperlukan untuk aplikasi ini)

if [ "$EUID" -ne 0 ]; then 
    echo "Jalankan dengan: sudo bash fix-apt-repo.sh"
    exit 1
fi

echo "=== Memperbaiki Error GPG WineHQ ==="
echo ""

# Nonaktifkan repository WineHQ yang menyebabkan error
WINE_FILES=$(find /etc/apt/sources.list.d/ -name "*wine*" 2>/dev/null)

if [ -n "$WINE_FILES" ]; then
    echo "Menonaktifkan repository WineHQ..."
    for file in $WINE_FILES; do
        if [ -f "$file" ]; then
            # Backup file
            cp "$file" "$file.backup"
            # Comment semua baris yang aktif
            sed -i 's/^deb /#deb /g' "$file"
            sed -i 's/^deb-src /#deb-src /g' "$file"
            # Untuk format .sources (Debian/Ubuntu baru)
            sed -i 's/^Enabled: yes/Enabled: no/g' "$file"
            echo "  ✓ $file dinonaktifkan (backup: $file.backup)"
        fi
    done
else
    echo "Repository WineHQ tidak ditemukan"
fi

# Update apt (sekarang seharusnya tidak ada error)
echo ""
echo "Testing apt update..."
apt update 2>&1 | tail -5

echo ""
echo "=== Selesai ==="
echo "Repository WineHQ sudah dinonaktifkan."
echo "Untuk mengaktifkan kembali: sudo bash -c 'cd /etc/apt/sources.list.d && mv *wine*.backup *wine*'"

