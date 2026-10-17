final: prev: let
  github-tags = ["yetidevworks/bosun" "2.2.4"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-YYbaxNyMW2p6tsNL5KOt3KgH3HJiYZpE91h+Jz4DiK4=";
  hash-cargo-deps = "sha256-CIMebgX+I3YLArLZTM4WFabneIswFzVbKmhl1Cjwb/4=";
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
