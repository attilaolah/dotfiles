final: prev: let
  github-tags = ["openai/codex" "0.171.0"]; # extractVersion=^rust-v(?<version>.*)$
  hash-src = "sha256-Q0fxlAU4oJZOHJtsVVaJJ28XuupzpCYGO4IKn9TAwl0=";
  hash-cargo-deps = "sha256-57GGsc4vgmQnnOXOPf2QaqrW8+02cpc/zotb8Y+rRio=";
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
