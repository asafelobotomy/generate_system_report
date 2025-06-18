# System Report Generation Script

This repository contains shell scripts to generate detailed system reports.
`generate_arch_report.sh` targets Arch Linux systems,
`generate_ubuntu_report.sh` performs the same tasks for Ubuntu and
Ubuntu-based distributions, and `generate_fedora_report.sh` is designed for
Fedora. The scripts can run with only standard utilities,
but installing a few optional tools allows them to gather extra information.

## Usage

Run the appropriate script directly from a terminal:

```bash
# For Arch Linux
bash generate_arch_report.sh

# For Ubuntu
bash generate_ubuntu_report.sh

# For Fedora
bash generate_fedora_report.sh
```

Each script checks for several optional helper utilities and offers to install
them if possible. A report file will be created in the current directory named
`system_report_<hostname>_<timestamp>.txt`.

## Prerequisites

`generate_arch_report.sh` expects an Arch Linux environment with the `pacman`
package manager available. If `pacman` cannot be found, package listings and
automatic installation of optional tools are skipped.

`generate_ubuntu_report.sh` expects an Ubuntu system with `apt-get` available.
If `apt-get` cannot be found, package listings and automatic installation of
optional tools are skipped. Installing packages requires root privileges, so
run the script as `root` or ensure `sudo` is configured.

`generate_fedora_report.sh` expects a Fedora system with `dnf` available. If
`dnf` cannot be found, package listings and automatic installation of optional
tools are skipped.

## Information Collected

The generated reports may include the following sections:

- Overall system summary from `inxi`
- CPU details via `lscpu`
- Memory statistics from `free`
- Block device list using `lsblk`
- PCI devices with `lspci`
- USB devices with `lsusb`
- Kernel and OS release information
- Disk usage from `df`
- Running services from `systemctl`
- Packages installed by the system package manager
- Manually installed packages
- Packages that can be autoremoved
- Pending package updates (and security status on Ubuntu if available)

Sections that rely on optional commands will be skipped if a tool is not
available.

## Optional Dependencies

To generate a complete report, these packages should be installed:

- `inetutils` for `hostname`
- `inxi` for a high-level system summary
- `pciutils` to list PCI devices
- `usbutils` to list USB devices
- `arch-audit` on Arch to check for security updates
- `update-notifier-common` on Ubuntu for `ubuntu-security-status`
- `dnf-plugins-core` on Fedora for `repoquery` and `updateinfo`

The scripts will prompt to install any missing optional packages automatically,
but you can decline and run with limited output.

## License

This project is distributed under the terms of the GNU General Public License
version 3. See the [LICENSE](LICENSE) file for the full license text.
