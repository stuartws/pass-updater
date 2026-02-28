#!/usr/bin/bash

# Stop Proton Pass if it's running
pid=$(pidof proton-pass)
if [[ -n $pid ]]; then
    kill $pid
fi

# Get Proton's JSON file which contains version information
json_url="https://proton.me/download/PassDesktop/linux/x64/version.json"
echo "Downloading $json_url"
curl -s -S -o /tmp/protonpass_version.json $json_url

# Extract URL, checksum, version, and release date from the JSON contents
rpm_url=$(jq -r '[.Releases.[] | select(.CategoryName=="Stable")][0].File[] | select(.Url | endswith(".rpm")).Url' /tmp/protonpass_version.json)
rpm_checksum=$(jq -r '[.Releases.[] | select(.CategoryName=="Stable")][0].File[] | select(.Url | endswith(".rpm")).Sha512CheckSum' /tmp/protonpass_version.json)
version=$(jq -r '[.Releases.[] | select(.CategoryName=="Stable")][0].Version' /tmp/protonpass_version.json)
releasedate=$(jq -r '[.Releases.[] | select(.CategoryName=="Stable")][0].ReleaseDate' /tmp/protonpass_version.json)
filename=${rpm_url##*/}

# Download the RPM file
echo "Downloading $filename"
curl -s -S -o /tmp/$filename $rpm_url

# Compare the RPM file against its hash, then install it
if echo $rpm_checksum /tmp/$filename | sha512sum --check --status; then
    echo "Installing $filename"
    sudo dnf -y install /tmp/$filename && echo -e "\nInstalled Proton Pass v$version released $(date -d $releasedate +"%d %b %Y")."
else
    echo -e "\nChecksum comparison failed - could not install."
fi

# Clean up
rm /tmp/protonpass_version.json
rm /tmp/$filename
