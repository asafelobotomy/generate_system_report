#!/usr/bin/env bash

set -euo pipefail

# Verify apt-get exists
if ! command -v apt-get &> /dev/null; then
  echo "apt-get not found. Package-related sections will be skipped."
  HAS_APT=0
else
  HAS_APT=1
  if (( EUID == 0 )); then
    APT_CMD="apt-get"
  else
    APT_CMD="sudo apt-get"
  fi
fi

# Define optional packages and commands
declare -A OPTIONAL_TOOLS=(
  [hostname]="inetutils"
  [inxi]="inxi"
  [lspci]="pciutils"
  [lsusb]="usbutils"
  [ubuntu-security-status]="update-notifier-common"
)

MISSING_PKGS=()

# Check for optional commands
for CMD in "${!OPTIONAL_TOOLS[@]}"; do
  if ! command -v "$CMD" &> /dev/null; then
    echo "Missing optional tool: $CMD"
    MISSING_PKGS+=("${OPTIONAL_TOOLS[$CMD]}")
  fi
done

# Prompt to install missing packages when apt-get is available
if (( HAS_APT )) && [[ ${#MISSING_PKGS[@]} -gt 0 ]]; then
  echo -e "\nThe following optional packages are missing:"
  echo "${MISSING_PKGS[@]}"
  read -rp "Would you like to install them now? [Y/n]: " REPLY
  REPLY=${REPLY,,}
  if [[ "$REPLY" =~ ^(y|yes)?$ ]]; then
    $APT_CMD update
    $APT_CMD install -y "${MISSING_PKGS[@]}"
  else
    echo "Continuing without installing missing packages. Some information may be skipped."
  fi
elif [[ ${#MISSING_PKGS[@]} -gt 0 ]]; then
  echo "The following optional packages are missing but cannot be installed automatically:"
  echo "${MISSING_PKGS[@]}"
fi

# Safely get hostname fallback
HOST=$(command -v hostname &> /dev/null && hostname || echo "unknown-host")

REPORT_FILE="system_report_${HOST}_$(date +%Y%m%d_%H%M%S).txt"

echo "Generating system report..."
{
  echo "======================"
  echo " System Information"
  echo "======================"
  command -v inxi &> /dev/null && inxi -Faz --no-host || echo "inxi not installed"

  echo -e "\n======================"
  echo " CPU Information"
  echo "======================"
  lscpu

  echo -e "\n======================"
  echo " Memory Information"
  echo "======================"
  free -h

  echo -e "\n======================"
  echo " Block Devices"
  echo "======================"
  lsblk

  echo -e "\n======================"
  echo " PCI Devices"
  echo "======================"
  command -v lspci &> /dev/null && lspci -v || echo "lspci not installed"

  echo -e "\n======================"
  echo " USB Devices"
  echo "======================"
  command -v lsusb &> /dev/null && lsusb || echo "lsusb not installed"

  echo -e "\n======================"
  echo " Kernel & OS"
  echo "======================"
  uname -a
  cat /etc/os-release

  echo -e "\n======================"
  echo " Disk Usage"
  echo "======================"
  df -h

  echo -e "\n======================"
  echo " Active Services"
  echo "======================"
  systemctl list-units --type=service --state=running

  echo -e "\n======================"
  echo " All Installed Packages"
  echo "======================"
  if (( HAS_APT )); then
    dpkg-query -W -f='${binary:Package}\t${Version}\n'
  else
    echo "apt-get not installed"
  fi

  echo -e "\n======================"
  echo " Manually Installed Packages"
  echo "======================"
  if (( HAS_APT )); then
    apt-mark showmanual
  else
    echo "apt-get not installed"
  fi

  echo -e "\n======================"
  echo " Orphaned Packages"
  echo "======================"
  if (( HAS_APT )); then
    apt-get -s autoremove | awk '/^Remv/ {print $2}' || echo "No orphaned packages found."
  else
    echo "apt-get not installed"
  fi

  echo -e "\n======================"
  echo " Pending Package Updates"
  echo "======================"
  if (( HAS_APT )); then
    apt list --upgradable 2>/dev/null
    command -v ubuntu-security-status &> /dev/null && ubuntu-security-status
  else
    echo "apt-get not installed"
  fi

} > "$REPORT_FILE"

echo "Report saved to: $REPORT_FILE"
