final: prev: let
  github-tags = ["containers/kubernetes-mcp-server" "0.1.1"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-mvWFYxI1m8awaNl7p1utQ7lLwCwVdm+6e8K/lbpBSv4=";
  hash-vendor = "sha256-iKexsARqV4pvYpjzd2nP79U6pzhEB7Ou5O6ET05iMQ4=";
  version = builtins.elemAt github-tags 1;
in {
  kubernetes-mcp-server = prev.buildGoLatestModule {
    pname = "kubernetes-mcp-server";
    inherit version;

    src = import ./lib/fetch_from_github_tuple.nix prev {
      inherit github-tags hash-src;
      rev = "v${version}";
    };

    vendorHash = hash-vendor;
    subPackages = ["cmd/kubernetes-mcp-server"];
    doCheck = true;
    checkPhase = ''
      runHook preCheck
      export GOFLAGS=''${GOFLAGS//-trimpath/}
      export HOME="$TMPDIR/home"
      mkdir -p "$HOME"
      go test $checkFlags $(go list ./... | grep -Ev '/(pkg/api|pkg/mcp)$')
      runHook postCheck
    '';

    meta = {
      description = "MCP server for Kubernetes";
      homepage = "https://github.com/containers/kubernetes-mcp-server";
      license = prev.lib.licenses.asl20;
      mainProgram = "kubernetes-mcp-server";
    };
  };
}
