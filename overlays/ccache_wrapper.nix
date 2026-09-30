final: prev:
if !prev.stdenv.hostPlatform.isLinux
then {}
else let
  extraConfig = ''
    export USE_CCACHE=1

    export CCACHE_DIR="/var/cache/ccache"
    export CCACHE_BASEDIR="''${NIX_BUILD_TOP:-$PWD}"
    export CCACHE_UMASK=007

    export CCACHE_COMPRESS=1
    export CCACHE_MAXSIZE="24G"

    export CCACHE_NOHASHDIR="1"
    export CCACHE_SLOPPINESS="${builtins.concatStringsSep "," [
      "pch_defines"
      "random_seed"
      "time_macros"
    ]}"

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
in {
  ccacheExtraConfig = extraConfig;
  ccacheWrapper = prev.ccacheWrapper.override {inherit extraConfig;};
}
