final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["sooperset/mcp-atlassian" "0.23.1"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-zbBsEBEfSvsS7dTbbvx2HG2GQhxGtvwVpYf4JPZVCKw=";

  version = elemAt github-tags 1;
in {
  inherit (final.python3Packages) mcp-atlassian;

  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _: {
        mcp-atlassian = pyFinal.buildPythonPackage {
          pname = "mcp-atlassian";
          inherit version;
          pyproject = true;

          src = fetchFromGitHubTuple {
            inherit github-tags hash-src;
            rev = "v${version}";
          };

          build-system = with pyFinal; [
            hatchling
            uv-dynamic-versioning
          ];

          dependencies = with pyFinal; [
            atlassian-python-api
            beautifulsoup4
            cachetools
            click
            fakeredis
            fastmcp
            httpx
            keyring
            markdown
            markdown-to-confluence
            markdownify
            mcp
            pydantic
            python-dateutil
            python-dotenv
            requests
            starlette
            thefuzz
            trio
            truststore
            types-python-dateutil
            tzdata
            unidecode
            urllib3
            uvicorn
          ];

          pythonRelaxDeps = [
            "fakeredis"
          ];
          pythonRemoveDeps = [
            "types-cachetools"
          ];

          doCheck = false;

          meta = {
            description = "MCP server for Atlassian products";
            homepage = "https://github.com/sooperset/mcp-atlassian";
            license = prev.lib.licenses.mit;
            mainProgram = "mcp-atlassian";
          };
        };
      })
    ];
}
