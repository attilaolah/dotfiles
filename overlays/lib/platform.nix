system: let
  inherit (builtins) elemAt length throw;

  parts = builtins.match "([^-]+)-([^-]+)" system;
  platform = elemAt parts 1;
  arch = elemAt parts 0;

  platformAliases = {
    darwin = "mac";
    linux = "linux";
  };
  archAliases = {
    aarch64 = "arm64";
    x86_64 = "x64";
  };
in
  assert parts != null && length parts == 2 || throw "Expected system in '<architecture>-<platform>' form, got '${system}'"; {
    inherit system;
    nix = {inherit arch platform;};
    arch = archAliases.${arch} or (throw "Unsupported architecture: ${arch}");
    platform = platformAliases.${platform} or (throw "Unsupported platform: ${platform}");
    os = platform;
  }
