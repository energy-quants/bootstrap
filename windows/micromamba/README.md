# `micromamba`


This script installs the `micromamba` package manager.

`micromamba` is a single-binary executable which implements the `conda`
packaging spec and is able to create `conda` environments.

The system install will install the executable in `C:/conda/bin` and will configure
environment and package directories in `C:/conda/envs` and `C:/conda/pkgs`
respectively.

The `$PROFILE.AllUsersAllHosts` profile will be updated to configure `micromamba` as
well as create a `mamba` alias for convenience. A default `.mambarc` file will be
written to `C:/conda`.

An environment `C:/conda/envs/bin` will be created and placed permanently on the path
to allow tools to be installed and available globally.

