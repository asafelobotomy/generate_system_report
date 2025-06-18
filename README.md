# System Report Generation Script

This repository contains a single shell script, `generate_system_report.sh`,
which builds a detailed text report describing many aspects of an Arch Linux
system. The script can run with only standard utilities, but installing a few
optional tools allows it to gather extra information.

## Usage

Run the script directly from a terminal:

```bash
bash generate_system_report.sh
```

It checks for several optional helper utilities and offers to install them via `pacman` if missing. A report file will be created in the current directory named `system_report_<hostname>_<timestamp>.txt`.

## Prerequisites

The script assumes an Arch Linux environment with the `pacman` package manager
available. If `pacman` cannot be found, package listings and automatic
installation of optional tools are skipped. Installing packages requires root
privileges, so run the script as `root` or ensure `sudo` is configured.

## Information Collected

The generated report may include the following sections:

- Overall system summary from `inxi`
- CPU details via `lscpu`
- Memory statistics from `free`
- Block device list using `lsblk`
- PCI devices with `lspci`
- USB devices with `lsusb`
- Kernel and OS release information
- Disk usage from `df`
- Running services from `systemctl`
- Packages installed by `pacman` (all, explicit, foreign, and orphaned)
- Pending security updates with `arch-audit`

Sections that rely on optional commands will be skipped if a tool is not
available.

## Optional Dependencies

To generate a complete report, these packages should be installed:

- `inetutils` for `hostname`
- `inxi` for a high-level system summary
- `pciutils` to list PCI devices
- `usbutils` to list USB devices
- `arch-audit` to check for security updates

The script will prompt to install any missing optional packages automatically, but you can
decline and run with limited output.

## License

This project is distributed under the terms of the GNU General Public License
version 3. See the [LICENSE](LICENSE) file for the full license text.
