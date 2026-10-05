final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["asheshgoplani/agent-deck" "1.16.26"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-uB2t4njAWC/tFcRSfpAstJvEEhrdQhvPq25R6E3amsU=";
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

    patches = [./agent_deck/tests.patch];

    vendorHash = hash-vendor;
    subPackages = ["cmd/agent-deck"];
    doCheck = true;
    doInstallCheck = true;

    # The upstream suite marks subprocess and external-service tests as short.
    checkFlags = ["-short"];
    checkPhase = ''
      runHook preCheck
      export GOFLAGS=''${GOFLAGS//-trimpath/}
      export TMPDIR=/tmp
      export HOME="$(mktemp -d)"
      export XDG_CACHE_HOME="$HOME/.cache"
      export XDG_CONFIG_HOME="$HOME/.config"
      export XDG_DATA_HOME="$HOME/.local/share"
      export XDG_STATE_HOME="$HOME/.local/state"
      mkdir -p "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

      # These packages require FHS paths, downloaded toolchains, live terminal services, or timing-sensitive streams.
      go test $checkFlags $(go list ./... | grep -Ev '/(${prev.lib.concatStringsSep "|" [
        "cmd/agent-deck"
        "conductor"
        "internal/core/daemon"
        "internal/git"
        "internal/session"
        "internal/tmux"
        "internal/tuitest"
        "internal/ui"
        "internal/web"
        "scripts"
        "tools/funccheck"
        "tools/visualcheck"
      ]})$')
      runHook postCheck
    '';
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
