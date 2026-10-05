final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["Daghis/teamcity-mcp" "2.12.8"]; # extractVersion=^teamcity-mcp-v(?<version>.*)$
  hash-src = "sha256-aLOyZQksasOP2pRSWM7SMoyDHOzSKcdhAAp7MQUTXzU=";
  hash-npm-deps = "sha256-7o0yzSONESBfXXLEg5XIsTEjcRu+7lBG6jTx1UHhObE=";

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
    doCheck = true;
    doInstallCheck = true;
    checkPhase = "npm run test -- --runInBand";

    nativeInstallCheckInputs = [prev.versionCheckHook];
    versionCheckProgram = "${placeholder "out"}/bin/teamcity-mcp";
    meta = {
      description = "MCP server for TeamCity";
      homepage = "https://github.com/Daghis/teamcity-mcp";
      license = prev.lib.licenses.mit;
      mainProgram = "teamcity-mcp";
    };
  };
}
