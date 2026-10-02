final: prev: let
  inherit (builtins) elemAt;

  github-tags = ["google-antigravity/antigravity-cli" "1.2.15"];
  version = elemAt github-tags 1;

  # Keep these as top-level `hash-*` variables (not inlined in `sources`):
  # `.github/workflows/renovate_overlay_hashes.yaml` parses and rewrites them.
  hash-src-aarch64-darwin = "sha256-Zvfp6HUKUG6KLKrtqt9HnwI4IPcSAVycVc+5GiiRUhs=";
  hash-src-aarch64-linux = "sha256-hRvavaOy62edDUa0aWKbkXUtHx10lxhRB0CLYMWMLjI=";
  hash-src-x86_64-darwin = "sha256-VgLXGjr8Fu4H/NC9gGhCNCRk947V/J/qaa3/0anipk0=";
  hash-src-x86_64-linux = "sha256-u9Sksp8On+H8LhNFtdRPoIVA5DAU2ka8LEv3DPBXRdg=";
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
