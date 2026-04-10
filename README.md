# Proton Pass Updater

A simple shell script to install or update [Proton Pass](https://proton.me/pass) on Linux (RPM-based distributions).

## What it does

1. Prompts for `sudo` credentials upfront before any downloading begins
2. Fetches the latest stable release information from Proton's servers
3. Exits early if the latest version is already installed
4. Downloads the latest `.rpm` package
5. Verifies the download against its SHA-512 checksum
6. Stops Proton Pass if it is currently running
7. Installs the package via `dnf`
8. Cleans up temporary files
9. Restarts Proton Pass if it was running before the update

## Requirements

- An RPM-based Linux distribution (e.g. Fedora, RHEL, CentOS)
- `bash`, `curl`, `jq`, `sha512sum` (part of `coreutils`), and `dnf` available on your system
- `sudo` privileges for package installation

## Usage

Make the script executable, then run it:

```bash
chmod +x pass-updater.sh
./pass-updater.sh
```

Consider linking the script to a directory on your $PATH:

```bash
ln -s $(realpath ./pass-updater.sh) ~/.local/bin/pass-updater
```

## Notes

- The script works for both fresh installs and updates.
- The script targets the **x64** Linux build of Proton Pass. If you are on a different architecture, update `json_url` in the script accordingly.
- The installer will abort and print an error if checksum verification fails, leaving your existing installation untouched.
