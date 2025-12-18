#!/bin/bash

# Setup Slave Replication Script
# Run on Slave Server (172.16.11.102)

echo "=== Setup MariaDB Slave Replication ==="
echo ""

# Variables - Update these if needed
MASTER_IP="172.16.8.13"
REPL_USER="repl"
REPL_PASS="repl_password"
MASTER_LOG_FILE="mariadb-bin.000007"
MASTER_LOG_POS="835"

echo "Master IP: $MASTER_IP"
echo "Replication User: $REPL_USER"
echo "Master Log File: $MASTER_LOG_FILE"
echo "Master Log Position: $MASTER_LOG_POS"
echo ""

echo "1. Stopping slave (if running)..."
sudo mysql -u root -proot -e "STOP SLAVE; RESET SLAVE ALL;"
echo "✓ Slave stopped and reset"

echo ""
echo "2. Importing database dump from master..."
sudo mysql -u root -proot < /tmp/full.sql
echo "✓ Database imported"

echo ""
echo "3. Configuring slave to connect to master..."
sudo mysql -u root -proot -e "
CHANGE MASTER TO
  MASTER_HOST='${MASTER_IP}',
  MASTER_USER='${REPL_USER}',
  MASTER_PASSWORD='${REPL_PASS}',
  MASTER_LOG_FILE='${MASTER_LOG_FILE}',
  MASTER_LOG_POS=${MASTER_LOG_POS};
"
echo "✓ Slave configured"

echo ""
echo "4. Starting slave..."
sudo mysql -u root -proot -e "START SLAVE;"
echo "✓ Slave started"

echo ""
echo "5. Checking slave status..."
sleep 2
SLAVE_STATUS=$(sudo mysql -u root -proot -e "SHOW SLAVE STATUS\G" | grep -E "(Slave_IO_Running|Slave_SQL_Running|Last_Error)")
echo "$SLAVE_STATUS"

echo ""
echo "=== Slave Setup Complete ==="
echo ""
echo "If both Slave_IO_Running and Slave_SQL_Running show 'Yes',"
echo "replication is working correctly."
echo ""
echo "You can now tell the master server to unlock tables."