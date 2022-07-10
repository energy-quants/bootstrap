#!/bin/bash

# parse command line arguments
set -euo pipefail
script_dir="$(cd "$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")" && pwd)"
. "${script_dir}/argparse/install.sh"


test "$(whoami)" == "root" || sudo -n whoami > /dev/null 2>&1 || {
    echo "ERROR: You must be root to install docker!"
    exit 1
}

set -x

apt-get update
apt-get install -y ca-certificates curl apt-transport-https gnupg lsb-release

# Add Docker's GPG key
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
    "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

if [ "${_arg_list_versions}" == "on" ]; then
    # List available versions and exit
    apt list -a docker-ce
    exit $?
fi

if [ "${_arg_version}" == "latest" ]; then
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
else
    apt-get install -y docker-ce="${_arg_version}" docker-ce-cli="${_arg_version}" containerd.io docker-compose-plugin
fi

docker version
