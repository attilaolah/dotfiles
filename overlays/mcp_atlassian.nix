final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["sooperset/mcp-atlassian" "0.23.1"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-zbBsEBEfSvsS7dTbbvx2HG2GQhxGtvwVpYf4JPZVCKw=";

  version = elemAt github-tags 1;
in {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: _pyPrev: {
        mcp-atlassian = pyFinal.buildPythonApplication {
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
            unidecode
            urllib3
            uvicorn
          ];

          pythonRelaxDeps = [
            "fakeredis"
            "markdown-to-confluence"
          ];
          pythonRemoveDeps = [
            "types-cachetools"
            "types-python-dateutil"
            "tzdata"
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

  mcp-atlassian = final.python3Packages.mcp-atlassian;
}
