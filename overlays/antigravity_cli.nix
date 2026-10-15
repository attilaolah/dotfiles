final: prev: let
  inherit (builtins) elemAt;

  github-tags = ["google-antigravity/antigravity-cli" "1.3.6"];
  version = elemAt github-tags 1;

  # Keep these as top-level `hash-*` variables (not inlined in `sources`):
  # `.github/workflows/renovate_overlay_hashes.yaml` parses and rewrites them.
  hash-src-aarch64-darwin = "sha256-ROLFpZgvZ5lFmcUzYl2Bt+1W9WhFLsEyOIvTDELtdGU=";
  hash-src-aarch64-linux = "sha256-DhFHLzduKUPG+BIoDepJsgSsw74VeUxmBKRpcsWZWxI=";
  hash-src-x86_64-darwin = "sha256-SIKX4ZpFzc3vvh96+aNpQxwRy/xqGUVbYdYQ7jCLb9c=";
  hash-src-x86_64-linux = "sha256-6I7YNcvEr1BPZN/iAXX1Vy3CpCXb+i/PVcA1i7RE2Aw=";
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
