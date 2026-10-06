final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["yetidevworks/bosun" "2.1.16"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-a2qBVsqV6Y1r+Qfy3bFoTmoBnDQmOuFJQOx1Vh5Ptbw=";
  hash-cargo-deps = "sha256-+9/HHMVl6Q8MjzutGZx+YaRRgZnt95bc7q4UDnudOD8=";

  version = elemAt github-tags 1;
in {
  bosun = prev.rustPlatform.buildRustPackage {
    pname = "bosun";
    inherit version;

    src = fetchFromGitHubTuple {
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
