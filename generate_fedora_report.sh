#!/bin/bash

# Verify dnf exists
if ! command -v dnf &> /dev/null; then
  echo "dnf not found. Package-related sections will be skipped."
  HAS_DNF=0
else
  HAS_DNF=1
  if (( EUID == 0 )); then
    DNF_CMD="dnf"
  else
    DNF_CMD="sudo dnf"
  fi
fi

# Define optional packages and commands
declare -A OPTIONAL_TOOLS=(
  [hostname]="inetutils"
  [inxi]="inxi"
  [lspci]="pciutils"
  [lsusb]="usbutils"
  [repoquery]="dnf-plugins-core"
)

MISSING_PKGS=()

# Check for optional commands
for CMD in "${!OPTIONAL_TOOLS[@]}"; do
  if ! command -v "$CMD" &> /dev/null; then
    echo "Missing optional tool: $CMD"
    MISSING_PKGS+=("${OPTIONAL_TOOLS[$CMD]}")
  fi
done

# Prompt to install missing packages when dnf is available
if (( HAS_DNF )) && [[ ${#MISSING_PKGS[@]} -gt 0 ]]; then
  echo -e "\nThe following optional packages are missing:"
  echo "${MISSING_PKGS[@]}"
  read -rp "Would you like to install them now? [Y/n]: " REPLY
  REPLY=${REPLY,,}
  if [[ "$REPLY" =~ ^(y|yes)?$ ]]; then
    $DNF_CMD install -y "${MISSING_PKGS[@]}"
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
  if (( HAS_DNF )); then
    dnf list installed
  else
    echo "dnf not installed"
  fi

  echo -e "\n======================"
  echo " Manually Installed Packages"
  echo "======================"
  if (( HAS_DNF )); then
    dnf history userinstalled || echo "dnf history userinstalled not supported"
  else
    echo "dnf not installed"
  fi

  echo -e "\n======================"
  echo " Orphaned Packages"
  echo "======================"
  if (( HAS_DNF )); then
    command -v repoquery &> /dev/null && repoquery --unneeded || echo "repoquery not installed"
  else
    echo "dnf not installed"
  fi

  echo -e "\n======================"
  echo " Pending Package Updates"
  echo "======================"
  if (( HAS_DNF )); then
    dnf check-update || true
    dnf updateinfo list security 2>/dev/null || echo "dnf updateinfo plugin not installed"
  else
    echo "dnf not installed"
  fi

} > "$REPORT_FILE"

echo "Report saved to: $REPORT_FILE"
