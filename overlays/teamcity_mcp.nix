final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["Daghis/teamcity-mcp" "2.12.5"]; # extractVersion=^teamcity-mcp-v(?<version>.*)$
  hash-src = "sha256-K8oktslyLsoFazTI5OT50G7zUIEvYQXG4FWuPRNRjo8=";
  hash-npm-deps = "sha256-lXWj0rQqtCWDUhtF1rpFFOhtd/iuoNBaBA6ihBbZzws=";

  version = elemAt github-tags 1;
in {
  teamcity-mcp = prev.buildNpmPackage {
    pname = "teamcity-mcp";
    inherit version;

    src = fetchFromGitHubTuple {
      inherit github-tags hash-src;
      rev = "teamcity-mcp-v${version}";
    };

    npmDepsHash = hash-npm-deps;
    doCheck = false;

    meta = {
      description = "MCP server for TeamCity";
      homepage = "https://github.com/Daghis/teamcity-mcp";
      license = prev.lib.licenses.mit;
      mainProgram = "teamcity-mcp";
    };
  };
}
