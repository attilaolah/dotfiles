final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["asheshgoplani/agent-deck" "1.16.24"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-o/yXbK77iBM7AMOdZCWDvlBshgHedQvV/NYjP7UeQW4=";
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

    # These two upstream tests require an interactive terminal or a live remote peer.
    postPatch = ''
      substituteInPlace cmd/agent-deck/native_tui_ssh_test.go \
        --replace-fail \
        'func TestNativeSSHTUIRegistryLifecycle(t *testing.T) {' \
        'func TestNativeSSHTUIRegistryLifecycle(t *testing.T) {
          if testing.Short() { t.Skip("requires an interactive terminal") }'
      substituteInPlace cmd/agent-deck/recall_phase4_test.go \
        --replace-fail \
        'func TestRecallSearch_FederatedMergesAndLabels(t *testing.T) {' \
        'func TestRecallSearch_FederatedMergesAndLabels(t *testing.T) {
          if testing.Short() { t.Skip("requires a live remote peer") }'
    '';

    vendorHash = hash-vendor;
    subPackages = ["cmd/agent-deck"];
    doCheck = true;

    # The upstream suite marks subprocess and external-service tests as short.
    checkFlags = ["-short"];
    nativeCheckInputs = with prev; [
      git
      lsof
      openssh
      procps
      tmux
    ];

    nativeInstallCheckInputs = [prev.versionCheckHook];
    versionCheckProgram = "${placeholder "out"}/bin/agent-deck";
  };
}
