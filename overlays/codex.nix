final: prev: let
  github-tags = ["openai/codex" "0.166.0"]; # extractVersion=^rust-v(?<version>.*)$
  hash-src = "sha256-4zxnVT9PxIj0+ULQ4LSA46GmvfyNTueZ+BsQ2SZwk1I=";
  hash-cargo-deps = "sha256-3CHn33C1SSX+W0juZik3r8CVoYGoyNlk5mDICwVEcbY=";
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
