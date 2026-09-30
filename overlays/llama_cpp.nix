final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["ggml-org/llama.cpp" "11277"]; # extractVersion=^b(?<version>.*)$
  hash-src = "sha256-jUen7WrgFJ6iF+Hl1qvVNqVA7qPyDUhH2QcVbAk43UM=";
  hash-npm-deps = "sha256-2Q7XhaLAArmviOLdQsNbYTfdyDE5pW9lR26cRHEVl9k=";

  version = elemAt github-tags 1;
in {
  llama-cpp = prev.llama-cpp.overrideAttrs (_: {
    inherit version;
    npmDepsHash = hash-npm-deps;
    src = fetchFromGitHubTuple {
      inherit github-tags hash-src;
      rev = "b${version}";
    };
  });
}
