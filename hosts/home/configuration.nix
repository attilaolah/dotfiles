{pkgs, ...}: {
  imports = [
    ./boot.nix
    ./file_systems.nix
    ./fonts.nix
    ./hardware.nix
    ./networking.nix
    ./nix.nix
    ./programs
    ./services
    ./systemd.nix
    ./users
    ./virtualisation/docker.nix
    ./virtualisation/podman.nix
  ];
  system.stateVersion = "23.11";
  time.timeZone = "Europe/Zurich";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "de_CH.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
    extraLocales = [
      "de_DE.UTF-8/UTF-8"
    ];
  };

  console = {
    earlySetup = true;
    useXkbConfig = true; # use xkb.options
  };

  security = {
    polkit.enable = true;
    sudo.execWheelOnly = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-wlr
    ];
  };

  assertions = [
    (let
      v = "7.10.0";
    in {
      assertion = pkgs.suitesparse.version == v;
      message =
        "SuiteSparse changed from ${v} to ${pkgs.suitesparse.version};"
        + " check whether the CUDA workaround in hosts/home/configuration.nix is still needed.";
    })
  ];

  nixpkgs = {
    config = {
      cudaSupport = true;
      cudaCapabilities = ["8.6"];
      cudaForwardCompat = false;
    };
    overlays = [
      (_: prev: {
        cudaPackages = prev.lib.recurseIntoAttrs prev.cudaPackages_13_2;
        suitesparse = prev.suitesparse.override {
          # SuiteSparse 5.13.0..7.10.0 are not compatible with the CUDA 13 stdenv, but it is pulled into the desktop
          # closure through GEGL/GIMP. Drop this when nixpkgs updates SuiteSparse, likely via:
          # https://github.com/NixOS/nixpkgs/pull/486083
          enableCuda = false;
        };
      })
      (final: prev: {
        ccacheWrapper = prev.ccacheWrapper.override {
          extraConfig = ''
            export CCACHE_UMASK=007
            export CCACHE_COMPRESS=1
            export CCACHE_COMPRESSLEVEL=1
            export CCACHE_DIR="/var/cache/ccache"

            # Ignore build-dir paths and timestamps:
            export CCACHE_BASEDIR="/build"
            export CCACHE_SLOPPINESS=random_seed,file_macro,time_macros,include_file_mtime

            # Safety check inside the sandbox.
            # TODO: Remove once it turns out to be functional.
            if [ ! -w "$CCACHE_DIR" ]; then
              echo "ccache: $CCACHE_DIR is not writable by $(whoami)"
              exit 1
            fi
          '';
        };
      })
    ];
  };

  environment = {
    sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      NIXOS_OZONE_WL = "1"; # Wayland for Chrom{e,ium}
      QT_QPA_PLATFORM = "wayland";
    };
    systemPackages = with pkgs; [
      git
      slurp
      xdg-utils
    ];
  };
}
