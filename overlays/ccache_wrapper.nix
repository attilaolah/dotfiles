final: prev:
if !prev.stdenv.hostPlatform.isLinux
then {}
else let
  extraConfig = builtins.readFile ./ccache_wrapper/extra_config.sh;
in {
  ccacheExtraConfig = extraConfig;
  ccacheWrapper = prev.ccacheWrapper.override {inherit extraConfig;};
}
