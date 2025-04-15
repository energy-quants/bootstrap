#!/bin/bash

# parse command line arguments
set -euo pipefail
script_dir="$(cd "$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")" && pwd)"
. "${script_dir}/argparse/install.sh"


test "$(whoami)" == "root" || sudo -n whoami > /dev/null 2>&1 || {
    echo "ERROR: You must be root to install msodbc!"
    exit 1
}

set -x


apt-get -qq -o Dpkg::Use-Pty=0 update --yes
apt-get -qq -o Dpkg::Use-Pty=0 install --yes \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Microsoft GPG key
rm -f /usr/share/keyrings/microsoft-prod.gpg
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg

# Add MSSQL source
distribution="$(lsb_release -is)"
release="$(lsb_release -rs)"
codename="$(lsb_release -cs)"
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] \
https://packages.microsoft.com/${distribution@L}/${release}/prod ${codename} main" \
| tee /etc/apt/sources.list.d/microsoft-prod.list > /dev/null

apt-get update

if [ "${_arg_list_versions}" == "on" ]; then
    # List available versions and exit
    apt list -a msodbcsql18
    exit $?
fi

if [ "${_arg_version}" == "latest" ]; then
    ACCEPT_EULA=Y apt-get install -y msodbcsql18
else
    ACCEPT_EULA=Y apt-get install -y msodbcsql18="${_arg_version}"
fi

# cleanup
apt-get -qq clean
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/apt/archives/*
rm -rf /var/tmp/*
truncate -s 0 /var/log/*log
