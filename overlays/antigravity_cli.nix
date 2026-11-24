final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.5.16"];
  hash-src-aarch64-darwin = "sha256-ukcgL3Et5MSnj9eH2BuiBtc+Ecl1cvxpQg8pp378jZU=";
  hash-src-aarch64-linux = "sha256-fd7seQCE5VCvGK2wSltsX98ts+ECaFT0mQGgTLQmXH4=";
  hash-src-x86_64-darwin = "sha256-FM12ox5CrUYdb4rfdjEwbKw3VT9UeroKDxEbCCTSHAw=";
  hash-src-x86_64-linux = "sha256-m9qyNNBrrRphviMhByZS6wa+eLr/Gsv65HMx2loJCrw=";
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
