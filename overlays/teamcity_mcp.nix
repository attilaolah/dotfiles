final: prev: let
  github-tags = ["Daghis/teamcity-mcp" "2.12.15"]; # extractVersion=^teamcity-mcp-v(?<version>.*)$
  hash-src = "sha256-MWofcEv/Jyc8kokduJx+RJ4XtM5VVFfCaMu/hUT5G+k=";
  hash-npm-deps = "sha256-Y/GfXBx9Rob7t2ul6qI/sf5XxBsBZxJU01IkNJFNGWY=";
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
