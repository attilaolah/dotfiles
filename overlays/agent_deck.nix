final: prev: let
  github-tags = ["asheshgoplani/agent-deck" "1.16.36"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-D6PF5KWhiTwI+1M4XiT6KFv0+uO2PrdSWm9cjdSQofg=";
  hash-vendor = "sha256-yNCm//ZOTAIxUUm4yEPobbNw0dD01huAth6B9xvBaiE=";
  version = builtins.elemAt github-tags 1;
in {
  agent-deck = prev.buildGoLatestModule {
    pname = "agent-deck";
    inherit version;

    src = import ./lib/fetch_from_github_tuple.nix prev {
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
      # The fake vault inherits the production vault's deliberately restricted PATH.
      # Use store paths for its utilities without changing the environment under test.
      substituteInPlace internal/ask/helpers_test.go \
        --replace-fail 'env >>' '${prev.lib.getExe' prev.coreutils "env"} >>' \
        --replace-fail "| tr '/' '_'" "| ${prev.lib.getExe' prev.coreutils "tr"} '/' '_'" \
        --replace-fail 'then cat >&2' 'then ${prev.lib.getExe' prev.coreutils "cat"} >&2' \
        --replace-fail 'cat > "$store/$n"' '${prev.lib.getExe' prev.coreutils "cat"} > "$store/$n"'
      # On Darwin /tmp is a symlink to /private/tmp. The recall readers canonicalize discovered paths, while these
      # tests retain their t.TempDir paths for database lookups; use the canonical location.
      export TMPDIR=${
        if prev.stdenv.hostPlatform.isDarwin
        then "/private/tmp"
        else "/tmp"
      }
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
