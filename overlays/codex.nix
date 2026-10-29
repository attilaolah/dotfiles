final: prev: let
  github-tags = ["openai/codex" "0.165.0"]; # extractVersion=^rust-v(?<version>.*)$
  hash-src = "sha256-b9PpwNQeZsJIN4wbGA3FLfWAKd2EDMN5E/zj/Y62/vk=";
  hash-cargo-deps = "sha256-KKC/uHE2RWq0U7FmXA+TKTlFf/d8vYe6/G8gl78bW+g=";
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
