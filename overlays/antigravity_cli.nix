final: prev: let
  inherit (builtins) elemAt;

  github-tags = ["google-antigravity/antigravity-cli" "1.2.15"];
  version = elemAt github-tags 1;

  # Keep these as top-level `hash-*` variables (not inlined in `sources`):
  # `.github/workflows/renovate_overlay_hashes.yaml` parses and rewrites them.
  hash-src-aarch64-darwin = "sha256-Ro7cxFS2uxwyHY1CWRoWrOTRodYopPHOla0jbJ7kzBk=";
  hash-src-aarch64-linux = "sha256-O0DDuqskW0OkEAfB22TfUfXxYrYFn8xKRQRzHyaJ0wE=";
  hash-src-x86_64-darwin = "sha256-OTZMwk57KwWkoBOMYNXV2jnfn7dt7cnj9LdKFoUS/NY=";
  hash-src-x86_64-linux = "sha256-aM9NIhy2LgKJJFQ509N/WZvcjgxOHj2uA/MmRjoMJtw=";
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
