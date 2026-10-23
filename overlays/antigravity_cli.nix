final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.4.6"];
  hash-src-aarch64-darwin = "sha256-bWKNfSXfoYjvZ2Vk45cUZnxImbUr6mtWOdZZG8IrhpY=";
  hash-src-aarch64-linux = "sha256-iCa4DEsBPwh3NPJMXq3MOGAOdKGvQRJy1CqEDVLtPuc=";
  hash-src-x86_64-darwin = "sha256-neX/zCO8BNt4v44/5I1yV2xFeLlLYliIzpTSkA8wTQo=";
  hash-src-x86_64-linux = "sha256-kMwYlLaGJRCGmtTPGm9MBDt658CVutjVw1V4igypNcc=";
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
