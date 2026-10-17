final: prev: let
  github-tags = ["openai/codex" "0.163.0"]; # extractVersion=^rust-v(?<version>.*)$
  hash-src = "sha256-vYVQoXQdaK0bejUzcpf9uVrzNWWWAct9AsO/t261FAs=";
  hash-cargo-deps = "sha256-UTu+ws1DqL375C+1jaVI9HBqDHnTuAQr7/h1rSzsEzg=";
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
