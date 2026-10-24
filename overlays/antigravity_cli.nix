final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.4.7"];
  hash-src-aarch64-darwin = "sha256-n+17/pDLFYrAC1stpk3VSvcy98BiJZ5o69BguCf9DYg=";
  hash-src-aarch64-linux = "sha256-snPHkbdkf2gFmPodvfnICGvcQjdLInb6cOkAv4Eg4dU=";
  hash-src-x86_64-darwin = "sha256-CslEMfd0ZZ5xkoAZwmxknlcRF5YpuGlo6Wy5GT4uxVc=";
  hash-src-x86_64-linux = "sha256-Z/1OcL5zmx+LGPkLUR2ozSp67yToiOWDdALgJb9/2/w=";
  version = builtins.elemAt github-tags 1;
in {
  antigravity-cli = prev.antigravity-cli.overrideAttrs (old: let
    sources = prev.lib.mapAttrs (system: source:
      prev.fetchurl (source
        // {
          url = let
            platform = import ./lib/platform.nix system;
          in "https://github.com/google-antigravity/antigravity-cli/releases/download/${version}/agy_cli_${platform.platform}_${platform.arch}.tar.gz";
        })) {
      x86_64-linux.hash = hash-src-x86_64-linux;
      aarch64-linux.hash = hash-src-aarch64-linux;
      aarch64-darwin.hash = hash-src-aarch64-darwin;
      x86_64-darwin.hash = hash-src-x86_64-darwin;
    };
  in {
    inherit version;
    src =
      sources.${prev.stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${prev.stdenv.hostPlatform.system}");
    sourceRoot = ".";
    passthru = (old.passthru or {}) // {inherit sources;};
  });
}
