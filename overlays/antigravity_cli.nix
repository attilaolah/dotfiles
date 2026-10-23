final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.4.6"];
  hash-src-aarch64-darwin = "sha256-iFRRT8P1d8i0Jx5zWnYFVi7NNTquJwwyPD7mh26JIpY=";
  hash-src-aarch64-linux = "sha256-74jJlheLVaPFQW8si2epw0OsCmLJAOe3FY7i/xE1rZY=";
  hash-src-x86_64-darwin = "sha256-tJpNmONZLGkuIJQd4tqW0er5I03sk1Z0fmkifs5+UqI=";
  hash-src-x86_64-linux = "sha256-UTx0rT5wMjg5pl2NzMb5l3sJA+X6zZFMuwa+KDwrtkA=";
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
