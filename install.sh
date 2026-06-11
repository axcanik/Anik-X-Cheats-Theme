#!/bin/bash

# Define colors
CYAN='\033[0;36m'
LIGHT_CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Clear screen for a clean start
clear

# Display ASCII Art
echo -e "${LIGHT_CYAN}"
cat << "EOF"
    ___    _   __________ __   _  __   ________  __________  ____________
   /   |  / | / /  _/ //_/| | / / / /  / ____/ / / / ____/ | / /_  __/ __/
  / /| | /  |/ // // ,<   | |/ / / /  / /   / /_/ / __/ /  |/ / / / / /_  
 / ___ |/ /|  // // /| |  | / / / /___ / /___/ __  / /___/ /|  / / / / __/  
/_/  |_/_/ |_/___/_/ |_|  |__/ /_____/\____/_/ /_/_____/_/ |_/ /_/ /_/    
                                                                          
EOF
echo -e "${CYAN}========================================================================${NC}"
echo -e "${BOLD}${CYAN}                PTERODACTYL PREMIUM THEME INSTALLER                     ${NC}"
echo -e "${CYAN}========================================================================${NC}"
echo -e "${YELLOW}» Author:${NC} VΞLTRIX • ANIK"
echo -e "${YELLOW}» Discord:${NC} https://discord.gg/Wewfsd6uZf"
echo -e "${CYAN}========================================================================${NC}\n"

# Check root permissions
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[✖] Error: Please run this script as root.${NC}"
  exit
fi

# Check directory
if [ ! -d "/var/www/pterodactyl" ]; then
    echo -e "${RED}[✖] Error: Pterodactyl Panel not found in /var/www/pterodactyl!${NC}"
    exit 1
fi

# Function for a spinning loader
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf " \b\b\b\b"
}

# -----------------
# MENU SYSTEM
# -----------------
echo -e "${BOLD}Select an option from the menu below:${NC}"
echo -e "  ${LIGHT_CYAN}[1]${NC} Install ANIK X CHEATS Premium Theme"
echo -e "  ${LIGHT_CYAN}[2]${NC} Uninstall Theme (Restore Original Pterodactyl)"
echo -e "  ${LIGHT_CYAN}[3]${NC} Exit"
echo ""
read -p "Enter your choice (1/2/3): " choice

case $choice in
    1)
        echo -e "\n${CYAN}Starting Installation...${NC}"
        cd /var/www/pterodactyl

        echo -ne "${LIGHT_CYAN}[⌛] Downloading Theme Files...${NC}"
        (curl -sL -o gamenet_theme.zip https://raw.githubusercontent.com/axcanik/Anik-X-Cheats-Theme/refs/heads/main/gamenet_theme.zip) & spinner $!
        echo -e "\r${GREEN}[✔] Theme Files Downloaded!            ${NC}"

        echo -ne "${LIGHT_CYAN}[⌛] Extracting Theme Files...${NC}"
        (unzip -qo gamenet_theme.zip && rm gamenet_theme.zip) & spinner $!
        echo -e "\r${GREEN}[✔] Theme Extracted Successfully!         ${NC}"

        echo -ne "${LIGHT_CYAN}[⌛] Installing Node Dependencies...${NC}"
        (yarn install --silent > /dev/null 2>&1) & spinner $!
        echo -e "\r${GREEN}[✔] Node Dependencies Installed!                            ${NC}"

        echo -ne "${LIGHT_CYAN}[⌛] Building Production Assets (Please wait)...${NC}"
        (yarn build:production --silent > /dev/null 2>&1) & spinner $!
        echo -e "\r${GREEN}[✔] Assets Built Successfully!                      ${NC}"

        echo -ne "${LIGHT_CYAN}[⌛] Optimizing Panel & Fixing Permissions...${NC}"
        (php artisan view:clear > /dev/null 2>&1 && php artisan config:clear > /dev/null 2>&1 && chown -R www-data:www-data /var/www/pterodactyl/*) & spinner $!
        echo -e "\r${GREEN}[✔] Panel Optimized & Permissions Fixed!        ${NC}"

        echo -e "\n${BOLD}${GREEN}[✔] THEME INSTALLATION COMPLETED SUCCESSFULLY!${NC}"
        echo -e "${YELLOW}Please clear your browser cache (Ctrl + Shift + R) to see the new changes.${NC}\n"
        ;;
    2)
        echo -e "\n${YELLOW}Restoring Original Pterodactyl Theme...${NC}"
        cd /var/www/pterodactyl

        echo -ne "${LIGHT_CYAN}[⌛] Downloading Official Files...${NC}"
        (curl -sL https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv > /dev/null 2>&1) & spinner $!
        echo -e "\r${GREEN}[✔] Official Files Downloaded!            ${NC}"

        echo -ne "${LIGHT_CYAN}[⌛] Installing Node Dependencies...${NC}"
        (yarn install --silent > /dev/null 2>&1) & spinner $!
        echo -e "\r${GREEN}[✔] Node Dependencies Installed!                            ${NC}"

        echo -ne "${LIGHT_CYAN}[⌛] Building Production Assets (Please wait)...${NC}"
        (yarn build:production --silent > /dev/null 2>&1) & spinner $!
        echo -e "\r${GREEN}[✔] Assets Built Successfully!                      ${NC}"

        echo -ne "${LIGHT_CYAN}[⌛] Optimizing Panel & Fixing Permissions...${NC}"
        (chmod -R 755 storage/* bootstrap/cache/ && php artisan view:clear > /dev/null 2>&1 && php artisan config:clear > /dev/null 2>&1 && chown -R www-data:www-data /var/www/pterodactyl/*) & spinner $!
        echo -e "\r${GREEN}[✔] Panel Optimized & Permissions Fixed!        ${NC}"

        echo -e "\n${BOLD}${GREEN}[✔] ORIGINAL THEME RESTORED SUCCESSFULLY!${NC}"
        echo -e "${YELLOW}Please clear your browser cache (Ctrl + Shift + R) to see the original panel.${NC}\n"
        ;;
    3)
        echo -e "\n${RED}Installation cancelled. Exiting...${NC}\n"
        exit 0
        ;;
    *)
        echo -e "\n${RED}[✖] Invalid choice! Please run the command again and select 1, 2, or 3.${NC}\n"
        exit 1
        ;;
esac
