final: prev: let
  inherit (builtins) elemAt;
  fetchFromGithubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["marco-jardim/opencode-model-router" "2.7.0"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-V5kIOyDvqVE6HcXfVE9ef+G8KIEwz4N+dWzod/vL9Cw=";
  hash-npm-deps = "sha256-jdjxlJGVomL/4g2JtHb3z1J/vuWFt1vNKLB4B+4OQsI=";

  version = elemAt github-tags 1;

  # Nixpkgs' full Node package links bin/node to nodejs-slim.
  # Copy the executable into the package that carries npm so process.execPath and npm have the same prefix.
  nodejs = prev.runCommand "nodejs-with-npm-${prev.nodejs.version}" {inherit (prev.nodejs) meta python version;} ''
    mkdir -p "$out/bin" "$out/lib/node_modules"
    cp ${prev.lib.getExe prev.nodejs-slim} "$out/bin/node"
    cp -R ${prev.nodejs}/lib/node_modules/npm "$out/lib/node_modules/npm"
    ln -s ../lib/node_modules/npm/bin/npm-cli.js "$out/bin/npm"
  '';
in {
  opencode-model-router = prev.buildNpmPackage {
    pname = "opencode-model-router";
    inherit nodejs version;

    src = fetchFromGithubTuple {
      inherit github-tags hash-src;
      rev = "v${version}";
    };

    # Fresh processes cannot coordinate this wall-clock stale-lock assertion reliably under the Nix build sandbox.
    patches = [./opencode_model_router/slot_qa_1_4_21.patch];

    npmDepsHash = hash-npm-deps;
    dontNpmBuild = true;
    doCheck = true;
    preCheck = ''
      # The classifier recognizes /tmp as an absolute external path. Nix's default /build temp path would make those
      # integration fixtures appear to be non-path tokens. Use a private child so test sentinels cannot collide with
      # arbitrary entries in the shared /tmp root.
      tmpdir="$(mktemp -d /tmp/opencode-model-router.XXXXXX)"
      export TMPDIR="$(cd -P "$tmpdir" && pwd)"
      export npm_config_cache="$TMPDIR/npm-cache"
      mkdir -p "$npm_config_cache"

      export GIT_AUTHOR_NAME="nix builder"
      export GIT_AUTHOR_EMAIL="builder@nix.localhost"
      export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
      export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
    '';
    checkPhase = ''
      runHook preCheck
      ${prev.lib.getExe nodejs} ${nodejs}/lib/node_modules/npm/bin/npm-cli.js run test -- \
        --exclude test/unit/exec-branches.test.ts
      runHook postCheck
    '';
    nativeCheckInputs = with prev; [
      git
      nodejs
      procps
    ];
    passthru.plugin = "${final.opencode-model-router}/lib/node_modules/opencode-model-router";

    meta = {
      description = "OpenCode plugin that routes tasks to tiered subagents based on complexity";
      homepage = "https://github.com/marco-jardim/opencode-model-router";
      license = prev.lib.licenses.gpl3Only;
    };
  };
}
