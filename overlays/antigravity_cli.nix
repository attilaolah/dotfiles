final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.5.8"];
  hash-src-aarch64-darwin = "sha256-/JqJq83ARaancAhec+N30j0GeUD7V3c6FX8TfgvDgp8=";
  hash-src-aarch64-linux = "sha256-DKQHNXZhqiRPvDsOeaHR0mI7LKFRXS4vd6gBw2dr1WI=";
  hash-src-x86_64-darwin = "sha256-5M94y+YdGZCzGx1m3vF63Xy354PIeq58gRcmc1Fr48A=";
  hash-src-x86_64-linux = "sha256-kF1KzPvWG8AL7oS/ryTFm4XTNMq9eGz5kje2bP4Gq5g=";
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
