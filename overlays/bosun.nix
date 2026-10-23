final: prev: let
  github-tags = ["yetidevworks/bosun" "2.2.9"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-O8XtCdJTBpWsROzKez4IYIKZpk3N6IJnADqD94YHizU=";
  hash-cargo-deps = "sha256-Hs6z/t0KWvz0Wyu45siWWhjHeSJTXb6JAE5PZMgS6fM=";
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
