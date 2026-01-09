#!/bin/bash

CONFIG_FILE="config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    exit 1
fi

MINIO_PATH=$(jq -r '.minio_path' $CONFIG_FILE)
REMOTE=$(jq -r '.gdrive_remote' $CONFIG_FILE)
FOLDER=$(jq -r '.gdrive_folder' $CONFIG_FILE)
EXCLUDES=$(jq -r '.exclude[]' $CONFIG_FILE)

EXCLUDE_FLAGS=""
for item in $EXCLUDES; do
    EXCLUDE_FLAGS="$EXCLUDE_FLAGS --exclude $item"
done

rclone sync "$MINIO_PATH" "$REMOTE:$FOLDER" \
    $EXCLUDE_FLAGS \
    --local-no-check-updated \
    --drive-chunk-size 64M \
    --log-file=minio-backup.log \
    --v