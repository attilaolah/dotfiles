final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["DeusData/codebase-memory-mcp" "0.12.0"];
  hash-src = "sha256-2pTxcHa4KHpfZnR7IBN0/WKsxqFhRzTXAscIuf2tdwc=";
  hash-npm-deps = "sha256-MKXmiMUofKka1C1jwlm+Mq8X90cTMvipfTC3eX0iv60=";

  version = elemAt github-tags 1;
  src = fetchFromGitHubTuple {
    inherit github-tags hash-src;
    rev = "v${version}";
  };
in {
  codebase-memory-mcp = prev.codebase-memory-mcp.overrideAttrs (old: {
    inherit src version;
    npmDeps = prev.fetchNpmDeps {
      src = "${src}/graph-ui";
      hash = hash-npm-deps;
    };
  });
}
