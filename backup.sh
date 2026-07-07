#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

BASE_DIR=$(dirname "$(readlink -f "$0")")
CONFIG_FILE="$BASE_DIR/config.json"
LOG_FILE="$BASE_DIR/minio-backup.log"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[$(date)] Error: File konfigurasi tidak ditemukan di $CONFIG_FILE" >> "$LOG_FILE"
    exit 1
fi

# Membaca konfigurasi JSON
MINIO_PATH=$(jq -r '.minio_path' "$CONFIG_FILE")
REMOTE=$(jq -r '.gdrive_remote' "$CONFIG_FILE")
FOLDER=$(jq -r '.gdrive_folder' "$CONFIG_FILE")
EXCLUDES=$(jq -r '.exclude[]' "$CONFIG_FILE")

# Membaca metode backup (default ke "sync" jika tidak ada di config)
BACKUP_MODE=$(jq -r '.backup_mode // "sync"' "$CONFIG_FILE")

# Validasi mode rclone agar terhindar dari eksekusi yang salah
if [[ "$BACKUP_MODE" != "sync" && "$BACKUP_MODE" != "copy" ]]; then
    echo "[$(date)] Error: backup_mode di config.json harus berisi 'sync' atau 'copy'." >> "$LOG_FILE"
    exit 1
fi

# Menyusun flag exclude
EXCLUDE_FLAGS=""
for item in $EXCLUDES; do
    EXCLUDE_FLAGS="$EXCLUDE_FLAGS --exclude $item"
done

# Eksekusi rclone dengan metode yang dinamis
rclone --config="/home/teknovate/.config/rclone/rclone.conf" "$BACKUP_MODE" "$MINIO_PATH" "$REMOTE:$FOLDER" \
    $EXCLUDE_FLAGS \
    --local-no-check-updated \
    --drive-chunk-size 64M \
    --log-file="$LOG_FILE" \
    -v
