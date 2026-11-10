final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.5.4"];
  hash-src-aarch64-darwin = "sha256-tHA04TZ/w8nyhW8eGuML8SgZpyE4Ibo8ziEjsJDy34o=";
  hash-src-aarch64-linux = "sha256-LVAGDHsTJ5leXIHsWIKckcJWTruf7BZdP58TJewYhnU=";
  hash-src-x86_64-darwin = "sha256-8EcOrH+y+YiG4SEEV1Mb8Yg8Q5/6npnXMDiKH/Pf7vU=";
  hash-src-x86_64-linux = "sha256-G0hQWZzOc6F/lP+0It87+VMVMbd9vdxAwaQ14MLBaAc=";
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
