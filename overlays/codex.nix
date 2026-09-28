final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["openai/codex" "0.158.0"]; # extractVersion=^rust-v(?<version>.*)$
  hash-src = "sha256-iFW66odceRNBsVG5bD9SdcQGxhpm/QIZwYjGCrfMXiI=";
  hash-cargo-deps = "sha256-6IAX/SFSSgSKKFxKsUXoZ9nNQaHJ+EjZ5a4bJwyDdF0=";

  version = elemAt github-tags 1;
in {
  codex = prev.codex.overrideAttrs (_: let
    src = fetchFromGitHubTuple {
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
