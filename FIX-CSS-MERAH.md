# Fix: CSS Merah (Blocked) di Network Tab

## Masalah

Di Network tab browser (F12), CSS file menampilkan status **MERAH** (blocked) bukan hijau (200 OK).

## Penyebab

Browser memblokir semua resources karena:
1. **Certificate belum di-accept** (paling umum)
2. **Mixed content** (HTTP dan HTTPS tercampur)
3. **Browser security policy**

## Solusi Step-by-Step

### LANGKAH 1: Accept Certificate (WAJIB!)

**Ini adalah langkah PALING PENTING!**

1. **Buka browser** (Chrome/Firefox/Edge)

2. **Ketik di address bar:** `https://172.16.11.102`
   - JANGAN klik link, ketik manual
   - Pastikan menggunakan `https://` (bukan `http://`)

3. **Browser akan menampilkan halaman merah dengan warning:**
   ```
   Your connection is not private
   Attackers might be trying to steal your information
   NET::ERR_CERT_AUTHORITY_INVALID
   ```

4. **JANGAN klik:**
   - ❌ "Go back" 
   - ❌ "Back to safety"
   - ❌ "Return to previous page"

5. **Klik:**
   - ✅ "Advanced" (di bagian bawah, kecil)
   - ✅ "Show Details" (jika ada)

6. **Klik:**
   - ✅ "Proceed to 172.16.11.102 (unsafe)"
   - ✅ "Continue to 172.16.11.102"
   - ✅ "Accept the Risk and Continue"

7. **Halaman akan reload** dan certificate sudah di-accept

---

### LANGKAH 2: Clear Cache & Hard Reload

1. **Clear cache:**
   - Tekan **Ctrl+Shift+Delete**
   - Pilih **"Cached images and files"**
   - Time range: **"All time"**
   - Klik **"Clear data"**

2. **Hard reload:**
   - Tekan **Ctrl+F5** (atau **Shift+F5**)
   - Atau **Ctrl+Shift+R**

---

### LANGKAH 3: Verifikasi di Network Tab

1. **Buka Developer Tools:** Tekan **F12**

2. **Tab Network:**
   - Reload page (F5)
   - Filter: **CSS**
   - Cek file `material-dashboard.css`

3. **Status harus berubah:**
   - ❌ **MERAH** (blocked) → Certificate belum di-accept
   - ✅ **HIJAU** (200 OK) → Certificate sudah di-accept, CSS ter-load

---

## Troubleshooting

### CSS Masih Merah Setelah Accept Certificate

**Kemungkinan:**
1. Cache browser masih menyimpan blocked state
2. Browser belum benar-benar accept certificate
3. Mixed content

**Solusi:**

1. **Coba Incognito/Private Mode:**
   - Chrome: **Ctrl+Shift+N**
   - Firefox: **Ctrl+Shift+P**
   - Akses: `https://172.16.11.102`
   - Accept certificate
   - Lihat Network tab, CSS harus hijau

2. **Cek Console (F12 → Console):**
   - Lihat error message
   - Jika ada "Mixed Content" → Pastikan semua URL menggunakan HTTPS

3. **Cek Certificate di Browser:**
   - Klik icon **gembok** di address bar
   - Klik **"Certificate"**
   - Pastikan certificate sudah di-accept
   - Jika masih "Not secure" → Accept lagi

4. **Restart Browser:**
   - Tutup semua tab browser
   - Restart browser
   - Akses lagi `https://172.16.11.102`
   - Accept certificate

---

### CSS Hijau Tapi Masih Tidak Muncul

**Kemungkinan:**
1. CSS ter-load tapi ada error di CSS
2. CSS ter-override oleh inline style
3. Browser extension memblokir

**Solusi:**

1. **Cek Response di Network tab:**
   - Klik file CSS (material-dashboard.css)
   - Tab "Response"
   - Pastikan isi CSS muncul (bukan error)

2. **Cek Console:**
   - F12 → Console
   - Lihat apakah ada error CSS parsing

3. **Disable extension:**
   - Coba disable semua extension
   - Reload page

---

## Verifikasi Final

Setelah semua langkah:

1. ✅ Certificate sudah di-accept
2. ✅ Cache sudah di-clear
3. ✅ Hard reload sudah dilakukan
4. ✅ Network tab: CSS status **HIJAU (200 OK)**
5. ✅ CSS muncul di halaman
6. ✅ Kamera bisa diakses

---

## Catatan Penting

- **Certificate warning adalah NORMAL** untuk self-signed certificate
- **Browser akan memblokir SEMUA resources** sampai certificate di-accept
- **CSS merah = blocked = certificate belum di-accept**
- **CSS hijau = 200 OK = certificate sudah di-accept**

Jika CSS masih merah setelah semua langkah, kemungkinan:
- Browser policy yang sangat ketat
- Corporate/enterprise browser setting
- Antivirus memblokir

Coba browser lain atau incognito mode untuk memastikan.

