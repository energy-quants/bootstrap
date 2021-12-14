#!/bin/bash

# parse command line arguments
set -euo pipefail
script_dir="$(cd "$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")" && pwd)"
. "${script_dir}/install-parsing.sh"
set -x

# download mambaforge if no installer file was specified
# shellcheck disable=SC2154
if test -z "${_arg_filepath}"; then
    # If --filepath was not specified then download the installer script
    tmpdir=$(mktemp -d "${TMPDIR:-/tmp/}$(basename "$0").XXXXXXXXXXXX")
    filepath=$("${script_dir}/download.sh" --version "${_arg_version}" --output-path "${tmpdir}")
    function cleanup {
        rm -rf "${tmpdir}"
    }
    trap cleanup EXIT
else
    filepath=$(realpath -s "${_arg_filepath}")
fi

USER=${SUDO_USER:-${USER:-$(whoami)}}

# install mambaforge
chown "${USER}":"${USER}" "${filepath}"
prefix=/opt/mambaforge
mkdir -pv "${prefix}/envs"
chown -R "${USER}":"${USER}" "${prefix}/envs"
mkdir -pv "${prefix}/pkgs"
chown -R "${USER}":"${USER}" "${prefix}/pkgs"

bash "${filepath}" -b -p "${prefix}/envs/base"

# mambaforge shouldn't install a .condarc which will override the system defaults
rm -f "${prefix}/envs/base/.condarc"

# copy .condarc to system location
mkdir -v /etc/conda
cp "${script_dir}/.condarc" /etc/conda/.condarc

# initialise bash
"${prefix}/envs/base/bin/mamba" init -v --system bash
