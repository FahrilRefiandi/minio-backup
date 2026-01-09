#!/bin/bash

if ! command -v rclone &> /dev/null; then
    sudo curl https://rclone.org/install.sh | sudo bash
fi

if ! command -v jq &> /dev/null; then
    sudo apt update && sudo apt install jq -y
fi

if [ ! -f config.json.example ]; then
    cat <<EOF > config.json.example
{
  "minio_path": "",
  "gdrive_remote": "",
  "gdrive_folder": "",
  "exclude": [
    ".minio.sys/buckets/.usage-cache**",
    ".minio.sys/tmp/**",
    ".minio.sys/multipart/**",
    "**xl.meta.bkp"
  ]
}
EOF
fi

cp config.json.example config.json

read -p "Masukkan Path Source Minio: " minio_path
read -p "Masukkan Nama Remote Rclone: " remote_name
read -p "Masukkan Nama Folder di Google Drive: " folder_name

tmp=$(mktemp)
jq --arg mp "$minio_path" \
   --arg gr "$remote_name" \
   --arg gf "$folder_name" \
   '.minio_path = $mp | .gdrive_remote = $gr | .gdrive_folder = $gf' \
   config.json > "$tmp" && mv "$tmp" config.json

chmod +x backup.sh