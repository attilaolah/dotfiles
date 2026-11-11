final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.5.5"];
  hash-src-aarch64-darwin = "sha256-4Hn1umnVSEQwMdTZpmqZj+J4HG7pOAqbxulWW6fQk7c=";
  hash-src-aarch64-linux = "sha256-9vr/e0etLZpg68qdd0I5oc0j5TqMptgSwelYOQncplU=";
  hash-src-x86_64-darwin = "sha256-jELFzpTXStJVHrwtVQDmzWoEQ/ZfhQHaxfQZk3rTMCE=";
  hash-src-x86_64-linux = "sha256-v+LCXt6t2YwpQkF8mXLuDh+qPwr9yQcR6E1fOmM7UHg=";
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
