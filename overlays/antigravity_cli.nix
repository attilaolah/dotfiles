final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.5.6"];
  hash-src-aarch64-darwin = "sha256-h7itvLM9gdNinwSVhqsuarrrjGnS59QEJdyY5teu7no=";
  hash-src-aarch64-linux = "sha256-Qr/PmW4n9uYzMP90FQu7HWnIFjJYazf/RA6S64GVVSA=";
  hash-src-x86_64-darwin = "sha256-pcoCSEoT+iUsOv6y27ak5PQy3vaRX67+x9hJ+hEgOaI=";
  hash-src-x86_64-linux = "sha256-QI+QLab85aRe93fCRsGC9u8mPrFVzCZUi5EM28eS39k=";
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
