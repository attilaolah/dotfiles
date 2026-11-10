final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.5.4"];
  hash-src-aarch64-darwin = "sha256-GW5ndyegVC8ECpLkoZK++ES/tAvVbYkl3fo4mqrGWDQ=";
  hash-src-aarch64-linux = "sha256-qohw0bk7ZG7VL9CGJ1Kz7Ixeka/SLZQ+sqmgsGcf2Tk=";
  hash-src-x86_64-darwin = "sha256-IU+PvOrMD3n6iGUBkjxqJU7gCAND06gp6hNuUfiz5tM=";
  hash-src-x86_64-linux = "sha256-lszP7G8gXbj6QBZTG9oVZ4J/HQVglSOHNa9ri1Wn99Y=";
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
