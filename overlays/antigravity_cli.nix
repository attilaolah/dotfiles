final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.5.19"];
  hash-src-aarch64-darwin = "sha256-TxYDyd6MmTqDoS7Aa3NCtvt8J4U+nZ+2x4YoZGHR/1A=";
  hash-src-aarch64-linux = "sha256-qjFv9FsNQLSe2D0p44ZYV/ygwSXzUPu508HLmmQLScQ=";
  hash-src-x86_64-darwin = "sha256-qFBycpY9WpPxi+3ln2uh78KfaXihk6TuXJrTmiR7mT4=";
  hash-src-x86_64-linux = "sha256-lxpKpwf7CIbU4d9fH1C617AapJLQsfE99Op0AultrpA=";
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
