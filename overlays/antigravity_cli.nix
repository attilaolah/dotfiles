final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.4.12"];
  hash-src-aarch64-darwin = "sha256-ZCBOFJdeYyrn8mkSvtSNSf/he7JxkJPKOMACdrHxNPA=";
  hash-src-aarch64-linux = "sha256-DnUZDVqkiw92I7IBz+9ULNNqEnmz0or6f6CZmDoHNJM=";
  hash-src-x86_64-darwin = "sha256-kwNENtRlCCEwiRooTwsl0M/Ua+V2wJ54we9twv8v/3c=";
  hash-src-x86_64-linux = "sha256-PYTjpGG5y/n/yd7t4VWgGSE4DpZPUagsC8UF24CuhSU=";
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
