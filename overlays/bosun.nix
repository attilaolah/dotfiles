final: prev: let
  github-tags = ["yetidevworks/bosun" "2.2.10"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-glEzMR0+8NHV7h7VFGArxAdC7EjBJYwnf2FTG62XCw0=";
  hash-cargo-deps = "sha256-MhRgMsGihGdJFMUPFhzNV2CkTEMkPfx64/Des91LpMM=";
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
    nativeCheckInputs = [prev.git];

    meta = {
      description = "Tmux-native orchestrator for AI agent sessions";
      homepage = "https://github.com/yetidevworks/bosun";
      license = prev.lib.licenses.mit;
      mainProgram = "bosun";
    };
  };
}
