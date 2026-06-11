#!/bin/bash

# ANIK X CHEATS Theme Installer for Pterodactyl (1-Click)
# Developer by VΞLTRIX • ANIK

echo -e "\e[36m=====================================================\e[0m"
echo -e "\e[36m        ANIK X CHEATS THEME INSTALLER                \e[0m"
echo -e "\e[36m        Developed by VΞLTRIX • ANIK                  \e[0m"
echo -e "\e[36m=====================================================\e[0m"
echo ""

# Check if pterodactyl is installed
if [ ! -d "/var/www/pterodactyl" ]; then
    echo -e "\e[31m[Error] Pterodactyl Panel not found in /var/www/pterodactyl!\e[0m"
    exit 1
fi

cd /var/www/pterodactyl

echo -e "\e[32m[1/4] Downloading Theme Files...\e[0m"
# TODO: Replace YOUR_DOWNLOAD_LINK with the actual direct link to gamenet_theme.zip
wget -q -O gamenet_theme.zip "https://raw.githubusercontent.com/axcanik/Anik-X-Cheats-Theme/refs/heads/main/gamenet_theme.zip"

if [ ! -f "gamenet_theme.zip" ]; then
    echo -e "\e[31m[Error] Failed to download theme files. Please check the link.\e[0m"
    exit 1
fi

echo -e "\e[32m[2/4] Extracting Theme Files...\e[0m"
unzip -o gamenet_theme.zip
rm gamenet_theme.zip

echo -e "\e[32m[3/4] Building Panel (This may take a few minutes)...\e[0m"
yarn install
yarn build:production

echo -e "\e[32m[4/4] Clearing Caches...\e[0m"
php artisan view:clear
php artisan config:clear
php artisan route:clear
php artisan optimize:clear
chown -R www-data:www-data /var/www/pterodactyl/*

echo -e "\e[36m=====================================================\e[0m"
echo -e "\e[32m      Theme Installed Successfully! Enjoy!           \e[0m"
echo -e "\e[36m=====================================================\e[0m"
