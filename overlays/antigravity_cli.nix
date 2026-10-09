final: prev: let
  inherit (builtins) elemAt;

  github-tags = ["google-antigravity/antigravity-cli" "1.3.2"];
  version = elemAt github-tags 1;

  # Keep these as top-level `hash-*` variables (not inlined in `sources`):
  # `.github/workflows/renovate_overlay_hashes.yaml` parses and rewrites them.
  hash-src-aarch64-darwin = "sha256-7144WzKv2kzxYSNou0vxVdP49MVdUUiGSfUIuu/nfIY=";
  hash-src-aarch64-linux = "sha256-+W7+yZyL2g0xaGdiLmX3kgugwrdKYtafzU7RPg6EEZ0=";
  hash-src-x86_64-darwin = "sha256-U+j6APgAX+biKGd9Q6swTcVOZ0Fv1WLc8AIdMb+0TTA=";
  hash-src-x86_64-linux = "sha256-DjE7MJ6ljHFDHOhruCCTajcA4X5E6rznvyJkYX3IIts=";
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
