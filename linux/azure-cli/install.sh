#!/bin/bash

# parse command line arguments
set -euo pipefail
script_dir="$(cd "$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")" && pwd)"
. "${script_dir}/argparse/install.sh"


test "$(whoami)" == "root" || sudo -n whoami > /dev/null 2>&1 || {
    echo "ERROR: You must be root to install the Azure CLI!"
    exit 1
}

set -x

apt-get update
apt-get install -y ca-certificates curl apt-transport-https gnupg lsb-release

# Add Microsoft GPG key
curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" |
    tee /etc/apt/sources.list.d/azure-cli.list

apt-get update

if [ "${_arg_list_versions}" == "on" ]; then
    # List available versions and exit
    apt list -a azure-cli
    exit $?
fi

if [ "${_arg_version}" == "latest" ]; then
    apt-get install -y azure-cli
else
    apt-get install -y azure-cli="${_arg_version}"
fi

az --version
