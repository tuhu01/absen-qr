#!/bin/bash

# Setup Master Replication Script
# Run on Master Server (172.16.8.13)

echo "=== Setup MariaDB Master Replication ==="
echo ""

# Variables
REPL_USER="repl"
REPL_PASS="repl_password"
NETWORK="172.16.%.%"

echo "1. Creating replication user..."
sudo mysql -u root -proot -e "
CREATE USER IF NOT EXISTS '${REPL_USER}'@'${NETWORK}' IDENTIFIED BY '${REPL_PASS}';
GRANT REPLICATION SLAVE ON *.* TO '${REPL_USER}'@'${NETWORK}';
FLUSH PRIVILEGES;
"
echo "✓ Replication user created"

echo ""
echo "2. Locking tables and getting master status..."
MASTER_STATUS=$(sudo mysql -u root -proot -e "FLUSH TABLES WITH READ LOCK; SHOW MASTER STATUS;" 2>/dev/null)
echo "$MASTER_STATUS"

# Extract File and Position
MASTER_FILE=$(echo "$MASTER_STATUS" | grep mariadb-bin | awk '{print $1}')
MASTER_POS=$(echo "$MASTER_STATUS" | grep mariadb-bin | awk '{print $2}')

echo ""
echo "Master Log File: $MASTER_FILE"
echo "Master Log Position: $MASTER_POS"
echo ""

echo "3. Dumping databases..."
mysqldump -u root -proot --all-databases --single-transaction > /tmp/full.sql
echo "✓ Database dump created at /tmp/full.sql"

echo ""
echo "4. IMPORTANT: Keep this terminal session open!"
echo "   Do not close until slave is configured and running."
echo ""
echo "   When slave is ready, run: UNLOCK TABLES; in this session"
echo ""
echo "=== Master Setup Complete ==="