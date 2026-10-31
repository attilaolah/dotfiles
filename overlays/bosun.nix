final: prev: let
  github-tags = ["yetidevworks/bosun" "2.2.12"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-KUS75FlOK02mtz5nP1YOaO43Qhuu8ZiPhcV9pUkQogA=";
  hash-cargo-deps = "sha256-Dy6aOMsO5fuSMzPj4ReHCopxdUVMkipdp83zfr/UE7c=";
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
