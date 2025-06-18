#!/bin/bash

# Verify pacman exists
if ! command -v pacman &> /dev/null; then
  echo "pacman not found. Package-related sections will be skipped."
  HAS_PACMAN=0
else
  HAS_PACMAN=1
  if (( EUID == 0 )); then
    PACMAN_CMD="pacman"
  else
    PACMAN_CMD="sudo pacman"
  fi
fi

# Define optional packages and commands
declare -A OPTIONAL_TOOLS=(
  [hostname]="inetutils"
  [inxi]="inxi"
  [lspci]="pciutils"
  [lsusb]="usbutils"
  [arch-audit]="arch-audit"
)

MISSING_PKGS=()

# Check for optional commands
for CMD in "${!OPTIONAL_TOOLS[@]}"; do
  if ! command -v "$CMD" &> /dev/null; then
  echo "Missing optional tool: $CMD"
  MISSING_PKGS+=("${OPTIONAL_TOOLS[$CMD]}")
  fi
done

# Prompt to install missing packages when pacman is available
if (( HAS_PACMAN )) && [[ ${#MISSING_PKGS[@]} -gt 0 ]]; then
  echo -e "\nThe following optional packages are missing:"
  echo "${MISSING_PKGS[@]}"
  read -rp "Would you like to install them now? [Y/n]: " REPLY
  REPLY=${REPLY,,} # to lowercase
  if [[ "$REPLY" =~ ^(y|yes)?$ ]]; then
    $PACMAN_CMD -S --needed "${MISSING_PKGS[@]}"
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
  echo " All Installed Packages (including dependencies)"
  echo "======================"
  if (( HAS_PACMAN )); then
    pacman -Q
  else
    echo "pacman not installed"
  fi

  echo -e "\n======================"
  echo " Explicitly Installed Packages"
  echo "======================"
  if (( HAS_PACMAN )); then
    pacman -Qe
  else
    echo "pacman not installed"
  fi

  echo -e "\n======================"
  echo " Foreign Packages (likely AUR or manually installed)"
  echo "======================"
  if (( HAS_PACMAN )); then
    pacman -Qm
  else
    echo "pacman not installed"
  fi

  echo -e "\n======================"
  echo " Orphaned Packages"
  echo "======================"
  if (( HAS_PACMAN )); then
    pacman -Qdt || echo "No orphaned packages found."
  else
    echo "pacman not installed"
  fi

  echo -e "\n======================"
  echo " Pending Security Updates"
  echo "======================"
  command -v arch-audit &> /dev/null && arch-audit || echo "arch-audit not installed"

} > "$REPORT_FILE"

echo "Report saved to: $REPORT_FILE"
