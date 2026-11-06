final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.5.2"];
  hash-src-aarch64-darwin = "sha256-IXm6g+tUKewZJg0CIZars8vl5l4R4sLvLRmvVkwVWNs=";
  hash-src-aarch64-linux = "sha256-xDpQgxAG2Vp2N6qcrXAA/am5u0s+zoxTzGxQibklQuo=";
  hash-src-x86_64-darwin = "sha256-95Uogs2rUQM57rZ9/l3oWFe04pB4ulbbbA5fKxtD8sI=";
  hash-src-x86_64-linux = "sha256-KmTM/F9mecJTdp8HYGFK9d4E2Nwe7uybl1K6TI3ZIlA=";
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
