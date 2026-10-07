final: prev: let
  inherit (builtins) elemAt;

  github-tags = ["google-antigravity/antigravity-cli" "1.3.1"];
  version = elemAt github-tags 1;

  # Keep these as top-level `hash-*` variables (not inlined in `sources`):
  # `.github/workflows/renovate_overlay_hashes.yaml` parses and rewrites them.
  hash-src-aarch64-darwin = "sha256-f8qfB8P9S3/8+MYZA61uoVUNCjV5C4CasHjua0qVgb8=";
  hash-src-aarch64-linux = "sha256-ygmyyebNNKRW3O7HrwGY1TrOsV6UIE9NjMo2AsXuUGI=";
  hash-src-x86_64-darwin = "sha256-8RDfoZDKKhPBLzZD+FN2SaEeA0FAzzswl2DuXxJYErc=";
  hash-src-x86_64-linux = "sha256-VHMcyO2P5KGEDDhia34yUcbcRIQ4f5gAXbpoJQf0lb4=";
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
