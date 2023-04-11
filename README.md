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

## Legacy setup script (to be removed):

```shell
$ curl https://raw.githubusercontent.com/attilaolah/dotfiles/main/install.sh | bash
```
