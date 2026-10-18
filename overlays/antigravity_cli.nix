final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.4.2"];
  hash-src-aarch64-darwin = "sha256-T+0kdNoxTxCc9QXxMl64QwevzVhiQua2kfB0/Rpz5qo=";
  hash-src-aarch64-linux = "sha256-CN1KLKUtUx/vHfrk7C+6/NVjQr+mlMgZOmDaKyb7GJg=";
  hash-src-x86_64-darwin = "sha256-qB9qSdP+HAeRntMy8jY/lRCVSf3QGVy+g0TSJu2v1OM=";
  hash-src-x86_64-linux = "sha256-Y5WDesDhk90/5Q8SKOHErqNFypljbVRASrfnQ5fUCRw=";
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
