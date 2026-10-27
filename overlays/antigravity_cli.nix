final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.4.8"];
  hash-src-aarch64-darwin = "sha256-7NH3s1knvCPtRJYTmusOObmcSxxj1fHzuPwlq1FedjE=";
  hash-src-aarch64-linux = "sha256-u+NMVr39z9m5pP0k90MPeoB3d7NWsha0GGL7bdlFDIA=";
  hash-src-x86_64-darwin = "sha256-zoUcma+5ohqMDK3rsbcVWpUf+6dnSQgfD9LAawp7KcM=";
  hash-src-x86_64-linux = "sha256-ixZfD8WE8Pkt0TGNw6CQcGrhiq3n02sLhiO4Wur4bFI=";
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
