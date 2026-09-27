final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["yetidevworks/bosun" "2.1.14"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-rkbRSsH1/hRqsTm6fuIEXJi5hnyeKGu3ZGVSm3/SALw=";
  hash-cargo-deps = "sha256-06ffDsfx1WvsimfJ1Tm0L0PlSMLXiFoLPYM1Zuoz+Vg=";

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
