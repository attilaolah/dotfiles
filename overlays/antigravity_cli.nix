final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.5.15"];
  hash-src-aarch64-darwin = "sha256-sBvdRZHhPd/LDgSb6nSun4PoCCmtz2SqpY9b+xpCWlQ=";
  hash-src-aarch64-linux = "sha256-5faaMSP6xml0swPZogHzgaD7MrPvhp2ROdqF1cr2eio=";
  hash-src-x86_64-darwin = "sha256-wUIUEUHLqpP05GkEt2NB40nz8reERfh385Ro3+YN2h4=";
  hash-src-x86_64-linux = "sha256-1YOGMi0gc+lrM/fMMrTpri22Io9YRANpcllnst5Ix7U=";
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
