final: prev: let
  github-tags = ["Daghis/teamcity-mcp" "2.12.10"]; # extractVersion=^teamcity-mcp-v(?<version>.*)$
  hash-src = "sha256-nc/nVgy3VovsjduYp3L7Y66pmJJJ8Zh12Sk7S7zOuVQ=";
  hash-npm-deps = "sha256-rcqyxcpUyvyHdRm+JUvfHlQVYadWSAEo/20dCl4cvrk=";
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
