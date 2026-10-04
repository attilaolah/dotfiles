final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["containers/kubernetes-mcp-server" "0.0.67"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-rejF9JsszB3ZirZhoK1VDbCH/P0Xzmh4TJw5j+okj+M=";
  hash-vendor = "sha256-TSB2jAWh2PlDHpvzA/rrBbjaR8sgyjivDO0vsbcuvgg=";

  version = elemAt github-tags 1;
in {
  kubernetes-mcp-server = prev.buildGoModule {
    pname = "kubernetes-mcp-server";
    inherit version;

    src = fetchFromGitHubTuple {
      inherit github-tags hash-src;
      rev = "v${version}";
    };

    vendorHash = hash-vendor;
    subPackages = ["cmd/kubernetes-mcp-server"];
    doCheck = true;

    meta = {
      description = "MCP server for Kubernetes";
      homepage = "https://github.com/containers/kubernetes-mcp-server";
      license = prev.lib.licenses.asl20;
      mainProgram = "kubernetes-mcp-server";
    };
  };
}
