final: prev: let
  github-tags = ["openai/codex" "0.172.0"]; # extractVersion=^rust-v(?<version>.*)$
  hash-src = "sha256-MDLBCNRb/1DNPZWegnF2yFDQU4IdSsgQcYOh0JV3EN8=";
  hash-cargo-deps = "sha256-baArx7G/DmmT+1k4ykHoBnVU73ta0F+Hai4hWBkHV/Q=";
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
