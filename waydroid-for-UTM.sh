#!/bin/bash
# Created by lurenJBD 2024.10.07

github_url="${github_url:="https://github.com"}"
url="${github_url}/lurenJBD/Waydroid-arm64only/releases/download/Lineage18.1-arm64only/lineage18.1_waydroid_arm64_only-userdebug.zip"

if [ "$(id -u)" -eq 0 ]; then
    echo "Do not run this script as root."
    exit 1
fi

if ! command -v apt &> /dev/null; then
    echo "apt not found, please use Ubuntu system."
    exit 1
fi

if [ "$1" = 'reinstall' ]; then
    echo "Cleaning up and reinstall waydroid ..."
    sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/applications/*aydroid* ~/.local/share/waydroid
    sudo rm -rf /etc/waydroid-extra/images/
    sudo apt update
    sudo apt install --reinstall waydroid -y
fi

if ! which waydroid >/dev/null 2>&1 ; then
    echo "Waydroid not yet installed"
    sudo apt update
    sudo apt install curl ca-certificates -y
    curl https://repo.waydro.id | sudo bash
    sudo apt install waydroid -y
fi

if [ ! -f ~/images.zip ]; then
    wget -O ~/images.zip $url
fi

if [ ! -f /etc/waydroid-extra/images/system.img ]; then
    sudo mkdir -p /etc/waydroid-extra/images/
    sudo unzip ~/images.zip -d /etc/waydroid-extra/images/
    sudo waydroid init -f
fi

# Fix audio issues
USER_ID=$(id -u)
sudo sed -i "s|^[[:space:]]*\"container_xdg_runtime_dir\": \"/run/xdg\",|\"container_xdg_runtime_dir\": \"/run/user/$USER_ID\",|" /usr/lib/waydroid/tools/config/__init__.py

waydroid show-full-ui
sleep 3
sudo waydroid upgrade -o

echo "All Done."

