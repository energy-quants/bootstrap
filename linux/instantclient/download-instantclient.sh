#!/bin/bash

set -euo pipefail
script_dir="$(cd "$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")" && pwd)"
. "${script_dir}/argparse/download-instantclient.sh"
set -x



function download {
    local path
    local base_url
    local url
    local filename
    local version="${1}"
    # Since the path must exist, can trim any trailing slash with realpath
    path=$(realpath -s "${2:-$(pwd)}")
    base_url="https://download.oracle.com/otn_software/linux/instantclient"
    if [[ "${version}" == "latest" ]]; then
        filename="instantclient-basiclite-linuxx64.zip"
        url="${base_url}/${filename}"
    else
        filename="instantclient-basiclite-linux.x64-${version}dbru.zip"
        url="${base_url}/${version//./}/${filename}"
    fi
    local filepath="${path}/${filename}"
    curl -fsSL -o "${filepath}" "${url}"
    echo "${filepath}"
}

# shellcheck disable=SC2154
download "${_arg_version}" "${_arg_output_path}"
