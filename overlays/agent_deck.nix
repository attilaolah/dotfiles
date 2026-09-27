final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["asheshgoplani/agent-deck" "1.16.21"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-kgJH7VymxvM/FWPNsAvc0c8ZxtNyw4yTRCpgIbk+9P8=";
  hash-vendor = "sha256-AChAtXMmFDfJzlqnUpgkyD1KCmLGxkPZtKsD0+Tnt7E=";

  version = elemAt github-tags 1;
in {
  agent-deck = prev.buildGoModule {
    pname = "agent-deck";
    inherit version;

    src = fetchFromGitHubTuple {
      inherit github-tags hash-src;
      rev = "v${version}";
    };

    vendorHash = hash-vendor;
    subPackages = ["cmd/agent-deck"];
    doCheck = false;
  };
}
