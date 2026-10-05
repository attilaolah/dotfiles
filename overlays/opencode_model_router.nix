final: prev: let
  inherit (builtins) elemAt;
  fetchFromGithubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["marco-jardim/opencode-model-router" "2.1.0"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-vx1Eo8i+2e/rihJodwe/+mV9NPqAxlVaCDhv5Gfe0js=";
  hash-npm-deps = "sha256-QheKoY5fu7+eZsnQm41RAEYwLGejwyoPNpfddwYbtwg=";

  version = elemAt github-tags 1;
in {
  opencode-model-router = prev.buildNpmPackage {
    pname = "opencode-model-router";
    inherit version;

    src = fetchFromGithubTuple {
      inherit github-tags hash-src;
      rev = "v${version}";
    };

    # This test coordinates wall-clock time across fresh processes, which is not reliable in the Nix build sandbox.
    patches = [./opencode_model_router/slot_qa_1_4_21.patch];

    npmDepsHash = hash-npm-deps;
    dontNpmBuild = true;
    doCheck = true;
    preCheck = ''
      export npm_config_cache="$TMPDIR/npm-cache"
      mkdir -p "$npm_config_cache"
    '';
    checkPhase = ''
      runHook preCheck
      npm run test -- --exclude test/unit/exec-branches.test.ts
      runHook postCheck
    '';
    nativeCheckInputs = with prev; [
      git
      procps
    ];
    passthru.plugin = "${final.opencode-model-router}/lib/node_modules/opencode-model-router/src/index.ts";

    meta = {
      description = "OpenCode plugin that routes tasks to tiered subagents based on complexity";
      homepage = "https://github.com/marco-jardim/opencode-model-router";
      license = prev.lib.licenses.gpl3Only;
    };
  };
}
