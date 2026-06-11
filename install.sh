#!/bin/bash

# ==============================================================================
# Gamenet Premium Arix Theme + Custom Domain Web Proxy Addon Auto-Installer
# Author: Anik X Cheats / Veltri
# ==============================================================================

set -e

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Variables ---
PTERO_DIR="/var/www/pterodactyl"
GITHUB_ZIP_URL="https://raw.githubusercontent.com/axcanik/Anik-X-Cheats-Theme/refs/heads/main/gamenet_theme_v2.zip"

# --- Helper Functions ---
print_info() {
    echo -e "${CYAN}[i] ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}[✓] ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}[!] ${1}${NC}"
}

print_error() {
    echo -e "${RED}[x] ${1}${NC}"
}

# --- ASCII Banner ---
clear
echo -e "${CYAN}"
cat << "EOF"
  ___        _ _      __  __   ____ _                _       
 / _ \      (_) | __  \ \/ /  / ___| |__   ___  __ _| |_ ___ 
| | | |_____| | |/ /   \  /  | |   | '_ \ / _ \/ _` | __/ __|
| |_| |_____| |   <    /  \  | |___| | | |  __/ (_| | |_\__ \
 \___/      |_|_|\_\  /_/\_\  \____|_| |_|\___|\__,_|\__|___/
                                                             
EOF
echo -e "${NC}"
echo -e "${GREEN}======================================================================${NC}"
echo -e "${GREEN}    Gamenet Premium Theme + Custom Domain Auto-Installer Initiated    ${NC}"
echo -e "${GREEN}======================================================================${NC}"
echo ""

# --- Pre-flight Checks ---
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root. Please use sudo or log in as root." 
   exit 1
fi

if [ ! -d "$PTERO_DIR" ]; then
    print_error "Pterodactyl installation not found in $PTERO_DIR!"
    print_warning "Please install Pterodactyl panel before running this addon installer."
    exit 1
fi

print_info "Phase 1: Preparing system..."

# --- Install essential packages ---
print_info "Checking and installing required system packages..."
apt-get update -y -qq >/dev/null 2>&1
apt-get install -y -qq sudo wget tar git certbot python3-certbot-nginx unzip curl >/dev/null 2>&1
print_success "All system dependencies installed."

# --- File Operations ---
print_info "Phase 2: Downloading and extracting theme files..."
cd $PTERO_DIR

print_info "Fetching latest package from GitHub..."
curl -sL -o gamenet_theme.zip "$GITHUB_ZIP_URL"
print_success "Download complete."

print_info "Extracting files (overwriting existing panel files)..."
unzip -o -q gamenet_theme.zip
print_success "Files extracted successfully."
rm -f gamenet_theme.zip

# --- Proxy & Permissions ---
print_info "Phase 3: Configuring reverse proxy permissions..."
chmod +x scripts/nginx_proxy.sh
echo "www-data ALL=(ALL) NOPASSWD: /var/www/pterodactyl/scripts/nginx_proxy.sh" > /etc/sudoers.d/pterodactyl_proxy
chmod 0440 /etc/sudoers.d/pterodactyl_proxy
print_success "Sudo privileges granted for Domain Proxy automation."

# --- Database Migrations ---
print_info "Phase 4: Running database migrations..."
php artisan migrate --force -q
print_success "Database tables updated."

# --- Dependencies & Build ---
print_info "Phase 5: Building User Interface..."
if ! command -v yarn &> /dev/null; then
    print_warning "Yarn not found. Installing Node.js 22.x and Yarn..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - >/dev/null 2>&1
    apt-get install -y -qq nodejs >/dev/null 2>&1
    npm install -g yarn >/dev/null 2>&1
    print_success "Node.js and Yarn installed."
fi

print_info "Installing UI dependencies (this may take a few minutes)..."
yarn install --silent >/dev/null 2>&1
print_success "UI dependencies installed."

print_info "Compiling production build..."
yarn build:production >/dev/null 2>&1
print_success "Production UI built successfully."

# --- Optimization ---
print_info "Phase 6: Finalizing and optimizing panel..."
php artisan view:clear -q
php artisan config:clear -q
php artisan cache:clear -q
chown -R www-data:www-data *
print_success "Cache cleared and permissions fixed."

# --- Done ---
echo ""
echo -e "${GREEN}======================================================================${NC}"
echo -e "${GREEN}                     INSTALLATION SUCCESSFUL                          ${NC}"
echo -e "${GREEN}======================================================================${NC}"
echo -e " ${CYAN}➤ Premium Theme & Custom Domain Addon are now fully active.${NC}"
echo -e " ${CYAN}➤ Your users can now add domains which will automatically get SSL.${NC}"
echo -e " ${YELLOW}➤ NOTE: Please perform a hard reload (Ctrl+Shift+R) in your browser.${NC}"
echo -e "${GREEN}======================================================================${NC}"
echo ""
