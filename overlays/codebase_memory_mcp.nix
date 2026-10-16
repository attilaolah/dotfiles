final: prev: let
  github-tags = ["DeusData/codebase-memory-mcp" "0.12.0"];
  hash-src = "sha256-2pTxcHa4KHpfZnR7IBN0/WKsxqFhRzTXAscIuf2tdwc=";
  hash-npm-deps = "sha256-MKXmiMUofKka1C1jwlm+Mq8X90cTMvipfTC3eX0iv60=";
  version = builtins.elemAt github-tags 1;

  src = import ./lib/fetch_from_github_tuple.nix prev {
    inherit github-tags hash-src;
    rev = "v${version}";
  };
in {
  codebase-memory-mcp = prev.codebase-memory-mcp.overrideAttrs (old: {
    inherit src version;
    npmDeps = prev.fetchNpmDeps {
      inherit src;
      sourceRoot = "${src.name}/${old.npmRoot}";
      hash = hash-npm-deps;
    };
  });
}
