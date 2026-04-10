#!/usr/bin/env bash
set -euo pipefail

reopen_protonpass() {
    # Reopen Proton Pass if it gets closed by the script
    if [[ -n ${wasrunning:-} ]]; then
        proton-pass > /dev/null 2>&1 & disown
    fi
}

# How to exit politely
trap 'reopen_protonpass; rm -f /tmp/protonpass_version.json ${filename:+/tmp/$filename}' EXIT

# Cache credentials (if supported)
sudo -v

# Get Proton's JSON file which contains version information
json_url="https://proton.me/download/PassDesktop/linux/x64/version.json"
echo "Downloading $json_url"
curl -fsSLo /tmp/protonpass_version.json "$json_url"


# Extract URL, checksum, version, and release date from the JSON contents
rpm_url="$(jq -r '[.Releases[] | select(.CategoryName=="Stable")][0].File[] | select(.Url | endswith(".rpm")).Url' /tmp/protonpass_version.json)"
rpm_checksum="$(jq -r '[.Releases[] | select(.CategoryName=="Stable")][0].File[] | select(.Url | endswith(".rpm")).Sha512CheckSum' /tmp/protonpass_version.json)"
version="$(jq -r '[.Releases[] | select(.CategoryName=="Stable")][0].Version' /tmp/protonpass_version.json)"
releasedate="$(jq -r '[.Releases[] | select(.CategoryName=="Stable")][0].ReleaseDate' /tmp/protonpass_version.json)"
filename="${rpm_url##*/}"

installed="$(rpm -q --queryformat '%{version}' proton-pass 2>/dev/null || true)"
if [[ "$installed" = "$version" ]]; then
    echo "Proton Pass is already at the latest version (v$version). Nothing to do."
    exit 0
fi

# Download the RPM file
echo "Downloading $filename"
curl -fsSLo "/tmp/$filename" "$rpm_url"

# Compare the RPM file against its hash, then install it
if echo "$rpm_checksum  /tmp/$filename" | sha512sum --check --status; then
    # Stop Proton Pass if it's running
    pid="$(pidof proton-pass || true)"
    if [[ -n ${pid:-} ]]; then
        kill "$pid"
        wasrunning=1
    fi

    echo "Installing $filename"
    sudo dnf -y install "/tmp/$filename" && echo -e "\nInstalled Proton Pass v$version released $(date -d "$releasedate" +"%Y-%m-%d")."
else
    echo -e "\nChecksum comparison failed - could not install." >&2
fi
