#!/bin/bash

# parse command line arguments
set -euo pipefail
script_dir="$(cd "$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")" && pwd)"
. "${script_dir}/argparse/install.sh"


USER=${SUDO_USER:-${USER:-$(whoami)}}
test "$(whoami)" == "root" || sudo -n whoami > /dev/null 2>&1 || {
    echo "ERROR: You must be root to install micromamba!"
    exit 1
}

echo "::group::Install µ-mamba..."
set -x

apt-get -qq -o Dpkg::Use-Pty=0 update --yes
apt-get -qq -o Dpkg::Use-Pty=0 install --yes bzip2 ca-certificates curl

curl -fsSL "https://micro.mamba.pm/api/micromamba/linux-64/${_arg_version}" | tar -xvj -C / bin/micromamba

mkdir -p /opt/mambaforge/pkgs
mkdir -p /opt/mambaforge/envs
chown -R "${USER}":"${USER}" /opt/mambaforge

cat << 'EOF' > "/etc/profile.d/configure-micromamba.sh"
#!/bin/bash

export MAMBA_ROOT_PREFIX='/opt/mambaforge'

if [[ -z "${CONDA_SHLVL+x}" ]]; then
    eval "$(/bin/micromamba shell hook -s posix)"
    if [[ -n "${MAMBA_DEFAULT_ENV-}" ]]; then
        micromamba activate "${MAMBA_DEFAULT_ENV}"
    fi
fi
eval "$(/bin/micromamba shell hook -s posix)"
binpath='/opt/mambaforge/envs/bin/bin'
if [[ ":$PATH:" != *":${binpath}:"* ]]; then
    PATH="${binpath}${PATH:+":$PATH"}"
fi
EOF

echo 'source /etc/profile.d/configure-micromamba.sh' >> /etc/bash.bashrc

cat << 'EOF' > "/opt/mambaforge/.mambarc"
update_dependencies: false
experimental_sat_error_message: true
repodata_use_zst: true
channels:
  - conda-forge
envs_dirs:
  - /opt/mambaforge/envs/
pkgs_dirs:
  - /opt/mambaforge/pkgs/
EOF

if [ "${_arg_cleanup}" == "on" ]; then
    # Clean up
    apt-get -qq clean
    rm -rf --one-file-system /var/lib/apt/lists/*
    rm -rf --one-file-system /var/cache/apt/archives/*
    rm -rf --one-file-system /var/tmp/*
    rm -rf --one-file-system /tmp/*
    truncate -s 0 /var/log/*log
fi

set +x
source /etc/profile.d/configure-micromamba.sh

micromamba create -n bin
micromamba info

echo "::endgroup::"

