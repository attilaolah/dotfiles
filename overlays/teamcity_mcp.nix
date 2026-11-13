final: prev: let
  github-tags = ["Daghis/teamcity-mcp" "2.12.16"]; # extractVersion=^teamcity-mcp-v(?<version>.*)$
  hash-src = "sha256-HvnXlj8/Qy0eoAlx+X06L4HUWYyf5VLMEBzBRsbdvIY=";
  hash-npm-deps = "sha256-M+CzRhfVSzE575fTxRQcSMZEzbJHwOiUPXOOS7vvadU=";
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
