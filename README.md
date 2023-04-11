# `$HOME` Directory

This repo contains the files necessary to set up my development environment
using [home-manager].

[home-manager]: https://github.com/nix-community/home-manager

## One-time setup

On a fresh system, the first step is to install the Nix package manager and
home-manager. On Debian, this can be done by running:

```
$ sudo apt install nix-setup-systemd
```

The contents of this repo need to be cloned to `~/.config/home-manager`, so
that the `home.nix` file ends up being located at
`~/.config/home-manager/home.nix`. Once that's done, run the home-manager
setup:

```
$ nix-shell '<home-manager>' --attr install
```

This will use the `home.nix` config from the repo and install per-user,
nix-managed versions of most binaries needed for day-to-day life. Additional
packages can be installed (or removed) as needed using `nix-env`, for example:

```
$ nix-env --install rawtherapee
```

To clean up, run `nix-env --uninstall pkgname` and run `nix-collect-garbage`.

## DuckDNS template

The DuckDNS template is not managed since it is only running in a single
container on one host at the moment.

```sh
#!/usr/bin/env bash

LOGFILE="/tmp/duckdns.log"

echo -n "$(date --rfc-3339=seconds) " > "${LOGFILE}"
echo url="https://www.duckdns.org/update?domains=home-attilaolah-eu&token={{token}}&ip=" \
    | curl -k -o - -K - \
    >> "${LOGFILE}"
echo >> "${LOGFILE}"
```

## System locale

To install system locales on the host, run the following:

```sh
echo en_US.UTF-8 UTF-8 | sudo tee /etc/locale.gen
echo en_GB.UTF-8 UTF-8 | sudo tee -a /etc/locale.gen
sudo locale-gen
```
