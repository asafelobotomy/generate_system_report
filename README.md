# System Report Generation Script

This repository contains shell scripts to generate detailed system reports.
`generate_system_report.sh` targets Arch Linux systems, while
`generate_ubuntu_report.sh` performs the same tasks for Ubuntu and
Ubuntu-based distributions. The scripts can run with only standard utilities,
but installing a few optional tools allows them to gather extra information.

## Usage

Run either script directly from a terminal:

```bash
# For Arch Linux
bash generate_system_report.sh

# For Ubuntu
bash generate_ubuntu_report.sh
```

Each script checks for several optional helper utilities and offers to install
them if possible. A report file will be created in the current directory named
`system_report_<hostname>_<timestamp>.txt`.

## Prerequisites

`generate_system_report.sh` assumes an Arch Linux environment with the `pacman`
package manager available. If `pacman` cannot be found, package listings and
automatic installation of optional tools are skipped.

`generate_ubuntu_report.sh` expects an Ubuntu system with `apt-get` available.
If `apt-get` cannot be found, package listings and automatic installation of
optional tools are skipped. Installing packages requires root privileges, so
run the script as `root` or ensure `sudo` is configured.

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

The scripts will prompt to install any missing optional packages automatically,
but you can decline and run with limited output.

## License

This project is distributed under the terms of the GNU General Public License
version 3. See the [LICENSE](LICENSE) file for the full license text.
