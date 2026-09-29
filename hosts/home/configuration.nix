{
  config,
  pkgs,
  ...
}: {
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
        suitesparse = prev.suitesparse.override {
          # SuiteSparse 5.13.0..7.10.0 are not compatible with the CUDA 13 stdenv, but it is pulled into the desktop
          # closure through GEGL/GIMP. Drop this when nixpkgs updates SuiteSparse, likely via:
          # https://github.com/NixOS/nixpkgs/pull/486083
          enableCuda = false;
        };
      })

      # CCache:
      (final: prev: let
        ccache = final.lib.getExe final.ccache;
        extraConfig = ''
          export USE_CCACHE=1
          export CCACHE_DIR="${config.programs.ccache.cacheDir}"
          export CCACHE_BASEDIR="$NIX_BUILD_TOP"
          export CCACHE_UMASK=007

          export CCACHE_COMPRESS=1
          export CCACHE_MAXSIZE="24G"

          export CCACHE_NOHASHDIR="1"
          export CCACHE_SLOPPINESS="${builtins.concatStringsSep "," [
            "pch_defines"
            "random_seed"
            "time_macros"
          ]}"

          export CUDA_NVCC_EXECUTABLE="${ccache} nvcc"

          if [ ! -d "$CCACHE_DIR" ]; then
            echo "Directory '$CCACHE_DIR' does not exist, create it with:"
            echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
            echo "  sudo chown root:nixbld '$CCACHE_DIR'"
            exit 1
          fi

          if [ ! -w "$CCACHE_DIR" ]; then
            echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami), verify its access permissions"
            exit 1
          fi
        '';
        cmakeConfig = ''
          ${extraConfig}

          export CMAKE_C_COMPILER_LAUNCHER="${ccache}"
          export CMAKE_CXX_COMPILER_LAUNCHER="${ccache}"
          export CMAKE_CUDA_COMPILER_LAUNCHER="${ccache}"
          export CMAKE_CUDA_COMPILER_LAUNCHER="${ccache}"
        '';
      in {
        ccacheWrapper = prev.ccacheWrapper.override {inherit extraConfig;};

        pythonPackagesExtensions =
          prev.pythonPackagesExtensions
          ++ [
            (_: pythonPrev: {
              torch = (pythonPrev.torch.override {stdenv = final.ccacheStdenv;}).overridePythonAttrs (oldAttrs: {
                preConfigure = (oldAttrs.preConfigure or "") + cmakeConfig;
              });
            })
          ];
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
