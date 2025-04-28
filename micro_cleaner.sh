#!/bin/bash

# Color codes
GREEN="\e[32m"
#RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# Service Check List
declare -A SERVICES=(
  ["snapd"]="Remove snaps system. Heavy, rarely needed."
  ["avahi-daemon"]="Remove mDNS discovery. Useless on servers."
  ["fwupd"]="Remove firmware updates. Useless on VMs."
  ["modemmanager"]="Remove modem support. Not needed."
  ["udisks2"]="Remove disk manager. Not needed."
  ["multipath-tools"]="Remove multi-disk mgmt. Not needed."
  ["network-manager"]="Replace with systemd-networkd if preferred."
  ["iscsid"]="Remove iSCSI initiator daemon. Rarely used."
  ["wpa_supplicant"]="Remove Wi-Fi support. No Wi-Fi here."
)

# Functions
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

ask_and_remove() {
  local service=$1
  local description=$2
  echo -e "${YELLOW}Detected: $service${RESET} - $description"
  read -rp "➔ Do you want to disable and purge $service? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Removing $service...${RESET}"
    systemctl disable --now "$service" 2>/dev/null || true
    apt purge -y "$service" || true
  else
    echo -e "${GREEN}Keeping $service.${RESET}"
  fi
}

# Main logic
echo -e "${GREEN}🔍 Scanning for unnecessary services...${RESET}"
for service in "${!SERVICES[@]}"; do
  if check_service "$service"; then
    ask_and_remove "$service" "${SERVICES[$service]}"
  fi
done

echo -e "${GREEN}🧹 Cleaning up orphaned packages...${RESET}"
apt autoremove -y
apt clean

# ZRAM Setup
echo -e "${GREEN}🔄 Setting up ZRAM swap...${RESET}"
apt install -y zram-tools
cat <<EOF > /etc/default/zramswap
ALGO=lz4
PERCENT=50
PRIORITY=100
EOF
systemctl restart zramswap

# EarlyOOM Install
echo -e "${GREEN}🧠 Installing EarlyOOM...${RESET}"
apt install -y earlyoom
systemctl enable --now earlyoom

# Journal cleanup
echo -e "${GREEN}🗒️ Configuring journald size limits...${RESET}"
mkdir -p /etc/systemd/journald.conf.d
cat <<EOF > /etc/systemd/journald.conf.d/cleanup.conf
[Journal]
SystemMaxUse=50M
SystemKeepFree=20M
MaxFileSec=7day
EOF
systemctl restart systemd-journald

echo -e "${GREEN}✅ Cleanup and optimization complete! Reboot recommended.${RESET}"
