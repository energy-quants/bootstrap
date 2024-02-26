#!/bin/bash

# parse command line arguments
set -euo pipefail
script_dir="$(cd "$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")" && pwd)"
. "${script_dir}/argparse/install.sh"


test "$(whoami)" == "root" || sudo -n whoami > /dev/null 2>&1 || {
    echo '::error::You must be root to install `simba-spark-odbc`!'
    exit 1
}

set -x


apt-get -qq -o Dpkg::Use-Pty=0 update --yes
apt-get -qq -o Dpkg::Use-Pty=0 install curl unixodbc unzip --yes


# Create a temp dir
tmpdir=$(mktemp -d "${TMPDIR:-/tmp/}$(basename "$0").XXXXXXXXXXXX")
function cleanup {
    rm -rf "${tmpdir}"
}
trap cleanup EXIT


# version='2.7.7.1016'
if [[ -z "${_arg_version}" ]]; then
    echo '::error::Required argument `--version` is not specified!'
    exit 1
else
    version="${_arg_version}"
fi
base_url="https://databricks-bi-artifacts.s3.us-east-2.amazonaws.com/simbaspark-drivers/odbc/${version%.*}"
filename="SimbaSparkODBC-${version}-Debian-64bit.zip"

curl -fsSLO --output-dir "${tmpdir}" "${base_url}/${filename}"

unzip "${tmpdir}/${filename}" -d "${tmpdir}"

for filepath in $(find "${tmpdir}" -type f -name "*.deb"); do
    sudo dpkg -i "${filepath}"
done
