final: prev: let
  github-tags = ["openai/codex" "0.169.0"]; # extractVersion=^rust-v(?<version>.*)$
  hash-src = "sha256-p8Vw0Vu8ufPY35k/RkcKE6HOTMJta2J9W33ei/7in+A=";
  hash-cargo-deps = "sha256-+YSkZwmAP88AOFmNWav4ye4ObbDYAIo0mzeQEzTqDm8=";
  version = builtins.elemAt github-tags 1;
in {
  codex = prev.codex.overrideAttrs (_: let
    src = import ./lib/fetch_from_github_tuple.nix prev {
      inherit github-tags hash-src;
      rev = "rust-v${version}";
    };
  in {
    inherit version src;
    cargoHash = hash-cargo-deps;
    cargoDeps = prev.rustPlatform.fetchCargoVendor {
      inherit src;
      cargoRoot = "codex-rs";
      hash = hash-cargo-deps;
    };
  });
}
