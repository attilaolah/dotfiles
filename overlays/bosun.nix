final: prev: let
  github-tags = ["yetidevworks/bosun" "2.2.6"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-x7eRReLOO+d9I9bTtdw7QFsD4XOWj9RA9/KI1XzzMzs=";
  hash-cargo-deps = "sha256-Rgi1JQI8ENtdqoWzZZ06rK0re0mwlG2LpfTlonL7yLs=";
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
