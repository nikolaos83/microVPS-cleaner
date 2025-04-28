#!/bin/bash

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# Service Check List
declare -A SERVICES=(
  ["snapd"]="Snap system (heavy, rarely needed)"
  ["avahi-daemon"]="mDNS discovery (useless on headless servers)"
  ["fwupd"]="Firmware update daemon (irrelevant for VMs)"
  ["modemmanager"]="USB modem support (not needed)"
  ["udisks2"]="Disk manager (not useful on static VMs)"
  ["multipath-tools"]="Multi-disk management (not needed)"
  ["network-manager"]="Network Manager (optional if using systemd-networkd)"
)

# Check if service or package exists
check_service() {
  local service=$1
  if systemctl list-units --type=service | grep -q "$service"; then
    return 0
  elif dpkg -l | grep -q "$service"; then
    return 0
  else
    return 1
  fi
}

# Prompt and remove
ask_and_remove() {
  local service=$1
  local description=$2
  echo -e "${YELLOW}Detected: $service${RESET} - $description"
  read -rp "\e[34m➔ Do you want to disable and purge $service? [y/N] \e[0m" answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Removing $service...${RESET}"
    systemctl disable --now "$service" 2>/dev/null || true
    apt purge -y "$service" || true
  else
    echo -e "${GREEN}Keeping $service.${RESET}"
  fi
}

# Start
clear
echo -e "${GREEN}🔍 Scanning for unnecessary services...${RESET}"

for service in "${!SERVICES[@]}"; do
  if check_service "$service"; then
    ask_and_remove "$service" "${SERVICES[$service]}"
  fi
  sleep 0.2
done

# Specific packages check and purge
for pkg in wpa_supplicant open-iscsi; do
  if dpkg -l | grep -q "^ii  $pkg"; then
    echo -e "${YELLOW}Detected installed package: $pkg${RESET}"
    read -rp "\e[34m➔ Do you want to purge $pkg? [y/N] \e[0m" answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      apt purge -y "$pkg"
    else
      echo -e "${GREEN}Keeping $pkg.${RESET}"
    fi
  fi
  sleep 0.2
done

# General Cleanup
echo -e "\n${GREEN}🧹 Cleaning up orphaned packages...${RESET}"
apt autoremove -y
apt clean

# ZRAM Setup
echo -e "\n${GREEN}🔄 Setting up ZRAM swap...${RESET}"
if ! systemctl list-units --type=service | grep -q zramswap; then
  apt install -y zram-tools
  systemctl restart zramswap
else
  echo -e "${BLUE}ZRAM swap already managed by system, skipping setup.${RESET}"
fi

# EarlyOOM Install
echo -e "\n${GREEN}🧠 Installing EarlyOOM for better memory handling...${RESET}"
apt install -y earlyoom
systemctl enable --now earlyoom

# Journald log limits
echo -e "\n${GREEN}🗒️ Configuring journald log size limits...${RESET}"
mkdir -p /etc/systemd/journald.conf.d
cat <<EOF > /etc/systemd/journald.conf.d/cleanup.conf
[Journal]
SystemMaxUse=50M
SystemKeepFree=20M
MaxFileSec=7day
EOF
systemctl restart systemd-journald

# Done
echo -e "\n${GREEN}✅ Cleanup and optimization complete! Reboot recommended.${RESET}"
