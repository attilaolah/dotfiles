final: prev: let
  inherit (builtins) elemAt;
  fetchFromGithubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["marco-jardim/opencode-model-router" "1.15.0"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-M7yGPLCzz/WwgzrlrDNR9tAoVPYdymjnGIFyOE0biTI=";
  hash-npm-deps = "sha256-HyWwG45IMhnUPxY6IauR1z0c8sdUZx+VKW0lbHlGHWk=";

  version = elemAt github-tags 1;
in {
  opencode-model-router = prev.buildNpmPackage {
    pname = "opencode-model-router";
    inherit version;

    src = fetchFromGithubTuple {
      inherit github-tags hash-src;
      rev = "v${version}";
    };

    npmDepsHash = hash-npm-deps;
    dontNpmBuild = true;
    doCheck = false;

    passthru.plugin = "${final.opencode-model-router}/lib/node_modules/opencode-model-router/src/index.ts";

    meta = {
      description = "OpenCode plugin that routes tasks to tiered subagents based on complexity";
      homepage = "https://github.com/marco-jardim/opencode-model-router";
      license = prev.lib.licenses.gpl3Only;
    };
  };
}
