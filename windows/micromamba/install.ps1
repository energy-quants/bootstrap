<#
.SYNOPSIS
Installs the micromamba package manager.

.DESCRIPTION
This script installs the micromamba package manager for a specified version or the latest version.

.PARAMETER version
Specifies the version of the micromamba binary to download. If not provided, the latest version is downloaded.

.FLAG system
If the `-system` flag is specified, the install will be performed for all users on the system under `C:/conda`.
Otherwise the install will be for the current user under `~/conda`


.EXAMPLE
.\install.ps1
Downloads the latest version of the micromamba binary.

.EXAMPLE
.\install.ps1 -version "1.0.0"
Downloads the micromamba binary for version 1.0.0.
#>


param(
    [string]$version = "latest",
    [switch]$system
)

$ErrorActionPreference = 'Stop';
$PSNativeCommandUseErrorActionPreference = $true


function Append-Path() {
    param (
        [Parameter(Mandatory=$true)][string]$new_path
    )
    $esc_path = [regex]::Escape($new_path)
    $path = [Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine);
    If ($path -inotmatch "(${esc_path})(;|$)") {
        $path = $path.Trim(';') + ';' + $new_path;
        [Environment]::SetEnvironmentVariable('PATH', $path, [System.EnvironmentVariableTarget]::Machine);
        [Environment]::SetEnvironmentVariable('PATH', $path, [System.EnvironmentVariableTarget]::Process);
    }
}

if ($system) {
    Write-Output "System install..."
}

mkdir -Force C:/temp
mkdir -Force C:/conda
mkdir -Force C:/conda/bin
mkdir -Force C:/conda/envs
mkdir -Force C:/conda/pkgs


Write-Output "Downloading micromamba version $version"
if ($version -eq "latest") {
    $url = "https://micro.mamba.pm/api/micromamba/win-64/latest"
} else {
    $url = "https://api.anaconda.org/download/conda-forge/micromamba/${version}/win-64/micromamba-${version}-0.tar.bz2"
}

echo $url
$mamba_prefix = 'C:/conda'

curl -fsSL $url -o C:/temp/micromamba.tar.bz2
C:\Windows\System32\tar.exe -xvj -C $mamba_prefix -f C:/temp/micromamba.tar.bz2 --strip-components 1 Library/bin/micromamba.exe
Remove-Item -Force C:/temp/micromamba.tar.bz2


[Environment]::SetEnvironmentVariable('MAMBA_ROOT_PREFIX', $mamba_prefix, [System.EnvironmentVariableTarget]::Machine);
[Environment]::SetEnvironmentVariable('MAMBA_ROOT_PREFIX', $mamba_prefix, [System.EnvironmentVariableTarget]::Process);
[Environment]::SetEnvironmentVariable('CONDA_PKGS_DIRS', "${mamba_prefix}/pkgs", [System.EnvironmentVariableTarget]::Machine);
[Environment]::SetEnvironmentVariable('CONDA_PKGS_DIRS', "${mamba_prefix}/pkgs", [System.EnvironmentVariableTarget]::Process);
[Environment]::SetEnvironmentVariable('CONDA_ENVS_PATH', "${mamba_prefix}/envs", [System.EnvironmentVariableTarget]::Machine);
[Environment]::SetEnvironmentVariable('CONDA_ENVS_PATH', "${mamba_prefix}/envs", [System.EnvironmentVariableTarget]::Process);

Append-Path "${mamba_prefix}/bin"
Append-Path "${mamba_prefix}/envs/bin/bin"
Append-Path "${mamba_prefix}/envs/bin/Library/bin"


$env:MAMBA_EXE = "${env:MAMBA_ROOT_PREFIX}/bin/micromamba.exe"
(& $env:MAMBA_EXE 'shell' 'hook' -s 'powershell') | Out-String | Invoke-Expression
if (-Not (Test-Path "${mamba_prefix}/envs/bin")) {
    Write-Host "Creating bin environment at '${mamba_prefix}/envs/bin'..."
    micromamba create -n bin --yes
}

Write-Output @'

Set-Alias -Name mamba -Value micromamba

#region mamba initialize
# !! Contents within this block are managed by 'mamba shell init' !!
$env:MAMBA_EXE = "${env:MAMBA_ROOT_PREFIX}/bin/micromamba.exe"
$script = (& $env:MAMBA_EXE 'shell' 'hook' -s 'powershell' -p $env:MAMBA_ROOT_PREFIX) | Out-String
Invoke-Expression $script
#endregion

if (Test-Path 'env:MAMBA_DEFAULT_ENV') {
    micromamba activate $env:MAMBA_DEFAULT_ENV
}
'@ >> $PROFILE.AllUsersAllHosts

Write-Output @'
update_dependencies: false
experimental_sat_error_message: true
repodata_use_zst: true
channels:
  - conda-forge
envs_dirs:
  - C:/conda/envs/
pkgs_dirs:
  - C:/conda/pkgs/
'@ > "${mamba_prefix}/.mambarc"

micromamba info
