#!/bin/bash

set -euo pipefail
script_dir="$(cd "$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")" && pwd)"
. "${script_dir}/download-parsing.sh"
set -x


function download {
    local path
    local redirect_url
    local url
    local version="${1}"
    # Since the path must exist, can trim any trailing slash with realpath
    path=$(realpath -s "${2:-$(pwd)}")

    if [[ "${version}" == "latest" ]]; then
        url="https://github.com/conda-forge/miniforge/releases/latest"
        redirect_url=$(curl -fsSIL -o /dev/null -w "%{url_effective}" "${url}")
        version=$(basename "${redirect_url}")
    fi
    local filename="Mambaforge-${version}-Linux-x86_64.sh"
    local filepath="${path}/${filename}"
    url="https://github.com/conda-forge/miniforge/releases/download/${version}/${filename}"
    curl -fsSL -o "${filepath}" "${url}"
    echo "${filepath}"
}

# shellcheck disable=SC2154
download "${_arg_version}" "${_arg_output_path}"
