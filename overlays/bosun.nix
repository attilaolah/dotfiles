final: prev: let
  github-tags = ["yetidevworks/bosun" "2.2.13"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-TKCnNsVWPDrjoOmgDilZk/feov6FpGCLLdPoTSs0qp0=";
  hash-cargo-deps = "sha256-sy9kzcv7SqJmL7eFZzgMSRIFOAS4br4gt6HJCHX7JAo=";
  version = builtins.elemAt github-tags 1;
in {
  bosun = prev.rustPlatform.buildRustPackage {
    pname = "bosun";
    inherit version;

    src = import ./lib/fetch_from_github_tuple.nix prev {
      inherit github-tags hash-src;
      rev = "v${version}";
    };

    cargoHash = hash-cargo-deps;

    buildInputs = with prev; [
      sqlite
      zstd
    ];
    nativeBuildInputs = with prev; [pkg-config];

    nativeCheckInputs = with prev; [git];

    meta = {
      description = "Tmux-native orchestrator for AI agent sessions";
      homepage = "https://github.com/yetidevworks/bosun";
      license = prev.lib.licenses.mit;
      mainProgram = "bosun";
    };
  };
}
