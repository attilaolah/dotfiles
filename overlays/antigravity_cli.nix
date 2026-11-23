final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.5.15"];
  hash-src-aarch64-darwin = "sha256-niUQjz6nDMbIRtiLk5dFbROuRyoBABbD1iXrP+ma/Do=";
  hash-src-aarch64-linux = "sha256-5bXXyh3aLP3AsJxykxMgw+9cSBoU29oTcwQQfObndrE=";
  hash-src-x86_64-darwin = "sha256-kf7gQ6OEt2zuXV8VaLlGqy8lvzjJOPC9fEsn/voMTkM=";
  hash-src-x86_64-linux = "sha256-jZkTKYYCBJ7ynpZp81JStreVcZec4b0PsndTx7rIQRQ=";
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
