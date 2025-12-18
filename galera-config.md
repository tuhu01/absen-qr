# Konfigurasi Galera Cluster untuk MariaDB

Panduan lengkap setup Galera Cluster untuk aplikasi Absensi QR Code.

## 📋 Prasyarat

- MariaDB Server dengan Galera support
- Minimal 2 server (recommended 3 untuk production)
- IP address yang dapat diakses antar server
- Firewall yang mengizinkan port: 3306, 4567, 4568, 4444

## 🚀 Setup Node Pertama (Bootstrap)

### 1. Install MariaDB + Galera
```bash
sudo apt update
sudo apt install mariadb-server mariadb-client galera-4
```

### 2. Konfigurasi MariaDB
Edit file `/etc/mysql/mariadb.conf.d/50-server.cnf` dan tambahkan:

```ini
# Galera Cluster Configuration
[galera]
# Mandatory settings
wsrep_on=ON
wsrep_provider=/usr/lib/galera/libgalera_smm.so
wsrep_cluster_address="gcomm://"
wsrep_cluster_name="absen_qr_cluster"
wsrep_node_address="IP_NODE_1"
wsrep_node_name="node1"

# Optional settings
wsrep_sst_method=rsync
binlog_format=row
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
bind-address=0.0.0.0

# Logging
wsrep_log_conflicts=ON
```

**Ganti `IP_NODE_1` dengan IP address server pertama**

### 3. Bootstrap Cluster
```bash
sudo galera_new_cluster
```

### 4. Verifikasi
```sql
SHOW STATUS LIKE 'wsrep_cluster_size';
-- Harus menampilkan: 1
```

## 🔗 Menambahkan Node Kedua dan Selanjutnya

### 1. Setup Server Baru
Ulangi langkah 1 (install MariaDB + Galera) di server baru.

### 2. Konfigurasi Node
Edit `/etc/mysql/mariadb.conf.d/50-server.cnf`:

```ini
# Galera Cluster Configuration
[galera]
# Mandatory settings
wsrep_on=ON
wsrep_provider=/usr/lib/galera/libgalera_smm.so
wsrep_cluster_address="gcomm://IP_NODE_1,IP_NODE_2,IP_NODE_3"
wsrep_cluster_name="absen_qr_cluster"
wsrep_node_address="IP_NODE_BARU"
wsrep_node_name="nodeX"

# Optional settings
wsrep_sst_method=rsync
binlog_format=row
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
bind-address=0.0.0.0

# Logging
wsrep_log_conflicts=ON
```

**Parameter yang perlu diganti:**
- `IP_NODE_1,IP_NODE_2,IP_NODE_3`: IP semua node yang sudah ada
- `IP_NODE_BARU`: IP server ini
- `nodeX`: nama node (node2, node3, dll)

### 3. Start Node
```bash
sudo systemctl start mariadb
```

### 4. Verifikasi Join Cluster
```sql
SHOW STATUS LIKE 'wsrep_cluster_size';
-- Harus menampilkan jumlah node yang benar
```

## 📊 Monitoring Cluster

### Status Cluster
```sql
-- Ukuran cluster
SHOW STATUS LIKE 'wsrep_cluster_size';

-- Status node
SHOW STATUS LIKE 'wsrep_local_state_comment';

-- Connected nodes
SHOW STATUS LIKE 'wsrep_incoming_addresses';
```

### Troubleshooting

#### Node Tidak Bisa Join
1. Cek koneksi: `telnet IP_NODE_1 4567`
2. Cek firewall: pastikan port 4567-4568, 4444 terbuka
3. Cek log: `sudo journalctl -u mariadb`
4. Restart node pertama jika perlu

#### SST Gagal
- Ganti `wsrep_sst_method` ke `mariabackup`
- Install: `sudo apt install mariadb-backup`

## 🔧 Konfigurasi Aplikasi

### Update .env
```dotenv
database.default.hostname = localhost
database.default.database = db_absensi
database.default.username = root
database.default.password = root
database.default.DBDriver = MySQLi
database.default.DBPrefix =
database.default.port = 3306
```

### Load Balancing (Opsional)
Gunakan HAProxy atau Nginx untuk distribute traffic:

```nginx
upstream mariadb_cluster {
    server IP_NODE_1:3306;
    server IP_NODE_2:3306;
    server IP_NODE_3:3306;
}
```

## 📋 Checklist Setup

- [ ] Install MariaDB + Galera di semua server
- [ ] Konfigurasi firewall (port 3306, 4567, 4568, 4444)
- [ ] Setup node pertama dengan `galera_new_cluster`
- [ ] Tambahkan node-node lainnya
- [ ] Test sinkronisasi database
- [ ] Update aplikasi untuk connect ke cluster
- [ ] Setup monitoring

## ⚠️ Catatan Penting

- **Minimal 3 node** untuk production
- **Backup data** sebelum migrasi
- **Test failover** secara berkala
- **Monitor performance** cluster
- Gunakan **SSD storage** untuk performa optimal

## 🆘 Emergency Recovery

Jika cluster corrupt, bootstrap ulang dari node terbaru:
```bash
# Di node yang akan dijadikan primary
sudo galera_new_cluster --wsrep-new-cluster
```

---

**Template ini dapat disalin dan dimodifikasi untuk setiap server baru.**