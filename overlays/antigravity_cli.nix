final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.5.18"];
  hash-src-aarch64-darwin = "sha256-8VT9voGIXDZWW3RhWp72x8kvucK8KaywowC8WZBpGHE=";
  hash-src-aarch64-linux = "sha256-l3mauskboLKbd1mLYvkDuGZGHaF2gCY6GC/vLLeWqw0=";
  hash-src-x86_64-darwin = "sha256-ET4FjfjD5IjJD2Trsdvfd2PKAa9wJ+z9c64YnzxTA2Y=";
  hash-src-x86_64-linux = "sha256-pJYHI+2c9bWscu1UHbjfTWJ0F5UmHrk6RoEAbMsj1a0=";
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
