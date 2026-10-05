final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["MatanYemini/bitbucket-mcp" "6.0.0"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-vzMVxAX+5Pn/CdgRVgCHAsB7b63Rv+BXctEyXV9UX8c=";
  hash-npm-deps = "sha256-7hq+Jtrx1iK6ut3Iaim9fbL7w4/bBpDKpCsMx5aGWZQ=";

  version = elemAt github-tags 1;
in {
  bitbucket-mcp = prev.buildNpmPackage {
    pname = "bitbucket-mcp";
    inherit version;

    src = fetchFromGitHubTuple {
      inherit github-tags hash-src;
      rev = "v${version}";
    };

    npmDepsHash = hash-npm-deps;
    doCheck = true;
    checkPhase = ''
      runHook preCheck
      npm run test
      runHook postCheck
    '';
    meta = {
      description = "MCP server for Bitbucket";
      homepage = "https://github.com/MatanYemini/bitbucket-mcp";
      license = prev.lib.licenses.mit;
      mainProgram = "bitbucket-mcp";
    };
  };
}
