#!/bin/bash

# parse command line arguments
set -euo pipefail
script_dir="$(cd "$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")" && pwd)"
. "${script_dir}/argparse/install.sh"

test "$(whoami)" == "root" || sudo -n whoami > /dev/null 2>&1 || {
    echo "ERROR: You must be root to install the Oracle Instant Client driver!"
    exit 1
}

set -x

apt update && apt install -y curl unixodbc unzip

# Unconditionally create a temp dir
tmpdir=$(mktemp -d "${TMPDIR:-/tmp/}$(basename "$0").XXXXXXXXXXXX")
function cleanup {
    rm -rf "${tmpdir}"
}
trap cleanup EXIT

# download instantclient if no installer file was specified
# shellcheck disable=SC2154
if test -z "${_arg_instantclient_filepath}"; then
    # If --instantclient-filepath was not specified then download the installer script
    instantclient_filepath=$("${script_dir}/download-instantclient.sh" --version "${_arg_version}" --output-path "${tmpdir}")
else
    instantclient_filepath=$(realpath -s "${_arg_filepath}")
fi

mkdir -p "/opt/oracle"
unzip "${instantclient_filepath}" -d "/opt/oracle"

# download odbc if no installer file was specified
# shellcheck disable=SC2154
if test -z "${_arg_odbc_filepath}"; then
    # If --odbc-filepath was not specified then download the installer script
    odbc_filepath=$("${script_dir}/download-odbc.sh" --version "${_arg_version}" --output-path "${tmpdir}")
else
    odbc_filepath=$(realpath -s "${_arg_filepath}")
fi

unzip "${odbc_filepath}" -d "/opt/oracle"
install_folder=$(cd "/opt/oracle"; echo *)


touch /etc/odbc.ini
touch /etc/odbcinst.ini
ln -s "/opt/oracle/${install_folder}" "/opt/oracle/instantclient"

set +u
. "/opt/oracle/instantclient/odbc_update_ini.sh" / /opt/oracle/instantclient

echo "/opt/oracle/instantclient/" > "/etc/ld.so.conf.d/oracle-instantclient.conf"
ldconfig
