#!/bin/bash

# parse command line arguments
set -euo pipefail
script_dir="$(cd "$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")" && pwd)"
. "${script_dir}/argparse/install.sh"


test "$(whoami)" == "root" || sudo -n whoami > /dev/null 2>&1 || {
    echo "ERROR: You must be root to install mambaforge!"
    exit 1
}

set -x

apt-get update
apt-get install -y ca-certificates curl apt-transport-https gnupg lsb-release

# Add Microsoft GPG key
curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

# Add MSSQL source
curl -sL https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list > /etc/apt/sources.list.d/mssql-release.list

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
