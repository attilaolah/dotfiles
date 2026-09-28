final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["openai/codex" "0.158.0"]; # extractVersion=^rust-v(?<version>.*)$
  hash-src = "sha256-6ogqs75pG4+hxG6RqwBwJPWd3wGks2wBID/epha9+Ds=";
  hash-cargo-deps = "sha256-D8+caV6Q9H2JnZNhazV1kqgV0dePh3qQyXnRMgeSYak=";

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
