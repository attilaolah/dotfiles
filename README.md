# `$HOME` Directory

This repo contains the files necessary to set up my development environment
using [home-manager].

[home-manager]: https://github.com/nix-community/home-manager

## One-time setup

On a fresh system, the first step is to grab a copy of the repository:

```sh
wget https://github.com/attilaolah/dotfiles/archive/refs/heads/main.zip \
  --output-document ~/dotfiles.zip
unzip ~/dotfiles.zip
mv dotfiles-main .config/home-manager
rm dotfiles.zip
```

The next step is to install the Nix package manager. On a Debian system, this
can be done by running:

```sh
sudo apt install nix-setup-systemd
sudo usermod --groups nix-users --append $USER
```

Then logout & log back in again for the group membership to take effect. On
Crostini, it might be necessary to "shut down" the Linux container and start it
again.

Once that's done, run the home-manager setup. Nothing below should require
superuser permissions any more.

```sh
rm -f .profile .bashrc .bash_profile .zshrc
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' --attr install
```

NOTE: If this fails with a complaint about `/nix/var/nix/gcroots`, re-running
the `nix-shell` command should solve the issue.

Once home-manager is done, logging out and back in should activate the right
shell and the environment should be ready to use. The `home.nix` file install
per-user, nix-managed versions of most binaries needed for day-to-day life.
Additional packages can be installed (or removed) as needed using `nix-env`,
for example:

```sh
nix-env --install rawtherapee
```

To clean up, run `nix-env --uninstall pkgname` and run `nix-collect-garbage`.

## Persistent modifications

To make changes to the system config files, replace the home-manager directory
with a Git repo. This can be done once the environment has an SSH key
configured.

```sh
rm -rf ~/.config/home-manager
git clone git@github.com:attilaolah/dotfiles ~/.config/home-manager
```

After making changes to the files in `~/.config/home-manager`, activate them by
running `home-manager switch`.

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
