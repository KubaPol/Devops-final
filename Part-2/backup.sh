#!/bin/bash

# Check rights
if [ "$(id -u)" != "0" ]; then
  echo "Run with sudo" >&2
  exit 1
fi

# Variables
BACKUP_DIR="/tmp/backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CA_SERVER="superpokemon25@84.201.189.183"
CA_BACKUP_DIR="/backup"
ALERTMANAGER_URL="http://localhost:9093/api/v2/alerts"
EMAIL="super.pokemon25@yandex.ru"
SSH_KEY="/root/.ssh/vpn_server_backup"
TRANSFER_SUCCESS=0
MAX_BACKUPS=2

# Create temp directory
mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

# Function to send alerts
send_alert() {
  local status="$1"
  local message="$2"
  curl -X POST -H "Content-Type: application/json" "$ALERTMANAGER_URL" -d "[{
      \"labels\": {
          \"alertname\": \"BackupStatus\",
          \"severity\": \"$status\",
          \"instance\": \"vpn-server\"
      },
      \"annotations\": {
          \"summary\": \"Backup $status\",
          \"description\": \"$message\"
      }
  }]"
}

# Backup files from vpn-server
tar -czf "${BACKUP_DIR}/vpn-config_${TIMESTAMP}.tar.gz" /etc/openvpn /etc/prometheus /etc/alertmanager || {
  send_alert "critical" "Failed to create backup of vpn-server configs"
  exit 1
}

# Backup files from ca-server
ssh -i "$SSH_KEY" "$CA_SERVER" "tar -czf - /home/superpokemon25/easy-rsa/pki" > "${BACKUP_DIR}/ca-pki_${TIMESTAMP}.tar.gz" 2>/dev/null || {
  send_alert "critical" "Failed to create backup of ca-server PKI"
  exit 1
}

# Send backups to ca-server
TRANSFER_SUCCESS=0
if scp -i "$SSH_KEY" "${BACKUP_DIR}/vpn-config_${TIMESTAMP}.tar.gz" "$CA_SERVER:$CA_BACKUP_DIR/" ; then
  TRANSFER_SUCCESS=$((TRANSFER_SUCCESS + 1))
  echo "Successfully transferred vpn-config_${TIMESTAMP}.tar.gz"
else
  send_alert "warning" "Failed to transfer vpn-server backup to ca-server, keeping local copy"
fi

if scp -i "$SSH_KEY" "${BACKUP_DIR}/ca-pki_${TIMESTAMP}.tar.gz" "$CA_SERVER:$CA_BACKUP_DIR/" ; then
  TRANSFER_SUCCESS=$((TRANSFER_SUCCESS + 1))
else
  send_alert "warning" "Failed to transfer ca-server backup to ca-server, keeping local copy"
fi

# Delete temp files only if transfer was successful
if [ $TRANSFER_SUCCESS -eq 2 ]; then
  echo "Both transfers successful, deleting temp files..."
  rm -f "${BACKUP_DIR}/vpn-config_${TIMESTAMP}.tar.gz" "${BACKUP_DIR}/ca-pki_${TIMESTAMP}.tar.gz"
  if [ $? -eq 0 ]; then
    echo "Temporary files deleted successfully."
  else
    echo "Failed to delete temporary files."
  fi
else 
  echo "Not all transfes were successfull, keeping temp files"
fi

#Verify new backups on ca-server
if [ $TRANSFER_SUCCESS -eq 2 ]; then
  ssh -i "$SSH_KEY" "$CA_SERVER" "ls /backup/vpn-config_${TIMESTAMP}.tar.gz /backup/ca-pki_${TIMESTAMP}.tar.gz" > /dev/null 2>&1 || {
    send_alert "critical" "New backups not found on ca-server after transfer"
    exit 1
  }
fi


#Clean up old backups on ca-server
if [ $TRANSFER_SUCCESS -eq 2 ]; then
  ssh -i "$SSH_KEY" "$CA_SERVER" "ls -t /backup/*.tar.gz | tail -n +$(($MAX_BACKUPS + 1)) | xargs -r rm -f"
  echo "Cleaned up old backups on ca-server, keeping the latest $MAX_BACKUPS."
fi

# Send success notification
send_alert "info" "Backup completed successfully at $TIMESTAMP, stored on ca-server"

echo "Backup completed successfully and sent to ca-server in $CA_BACKUP_DIR"
exit 0




