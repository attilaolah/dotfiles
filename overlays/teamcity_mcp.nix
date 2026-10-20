final: prev: let
  github-tags = ["Daghis/teamcity-mcp" "2.12.9"]; # extractVersion=^teamcity-mcp-v(?<version>.*)$
  hash-src = "sha256-2a2jEuvB/yNcqq2ck2BdJE5wqCbfqU3xteCau6Wr7jM=";
  hash-npm-deps = "sha256-tYwAYp0YjSCaN/52Z6fHgjhHhxJuJY9CGhH6vmHfaq4=";
  version = builtins.elemAt github-tags 1;
in {
  teamcity-mcp = prev.buildNpmPackage {
    pname = "teamcity-mcp";
    inherit version;

    src = import ./lib/fetch_from_github_tuple.nix prev {
      inherit github-tags hash-src;
      rev = "teamcity-mcp-v${version}";
    };

    npmDepsHash = hash-npm-deps;
    doCheck = true;
    doInstallCheck = true;
    checkPhase = ''
      runHook preCheck
      npm run test -- --runInBand
      runHook postCheck
    '';

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
