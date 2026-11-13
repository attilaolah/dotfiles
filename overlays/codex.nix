final: prev: let
  github-tags = ["openai/codex" "0.169.0"]; # extractVersion=^rust-v(?<version>.*)$
  hash-src = "sha256-9BVM0mUQ+F9QpqvnG+7x4ZXYaNTclcGLtF5DzEU5Zzg=";
  hash-cargo-deps = "sha256-Dqo9nMfbkTcyT+S79U2JdXpnxwrN0fQjjMlG055jvJE=";
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
