final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.4.4"];
  hash-src-aarch64-darwin = "sha256-hUgqqJaTABg/ccllPZ9YEkj7p/UGNCqOsIfz0lAyA70=";
  hash-src-aarch64-linux = "sha256-V6lqu8lHRaX69PJOh4dmoYgrmqTEuDulZ3F9ggZ0X1o=";
  hash-src-x86_64-darwin = "sha256-EslsBlrFDTbgh8H9obuo1vtPp68jLR7ypESZwkgaUr8=";
  hash-src-x86_64-linux = "sha256-muT38GZ6KGjhW7mtk4Gf91J8cYfxLRLjtRkRN8cmKHs=";
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
