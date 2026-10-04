final: prev: let
  inherit (builtins) elemAt;
  fetchFromGithubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["marco-jardim/opencode-model-router" "1.15.0"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-M7yGPLCzz/WwgzrlrDNR9tAoVPYdymjnGIFyOE0biTI=";
  hash-npm-deps = "sha256-HyWwG45IMhnUPxY6IauR1z0c8sdUZx+VKW0lbHlGHWk=";

  version = elemAt github-tags 1;
in {
  opencode-model-router = prev.buildNpmPackage {
    pname = "opencode-model-router";
    inherit version;

    src = fetchFromGithubTuple {
      inherit github-tags hash-src;
      rev = "v${version}";
    };

    postPatch = ''
      # These tests require capabilities unavailable in a sandboxed Nix build: a writable npm cache, wall-clock
      # coordination across fresh processes, or terminating the test runner's POSIX process group.
      substituteInPlace test/unit/packaging.test.ts \
        --replace-fail \
        'it("npm pack --dry-run ships only the allowlisted files", () => {'\
        'it.skip("npm pack --dry-run ships only the allowlisted files", () => {'
      substituteInPlace test/unit/slot.test.ts \
        --replace-fail \
        'it("fresh processes that each look once with waitMs 0 reclaim a lock whose owner is not provably dead, once unchanged for staleMs", async () => {' \
        'it.skip("fresh processes that each look once with waitMs 0 reclaim a lock whose owner is not provably dead, once unchanged for staleMs", async () => {'
      substituteInPlace test/integration/batch-wiring.test.ts \
        --replace-fail \
        'it("QA-2.2-25: a pooled batch that waits for the slot longer than its schedule allows runs its members alone", async () => {' \
        'it.skip("QA-2.2-25: a pooled batch that waits for the slot longer than its schedule allows runs its members alone", async () => {'
    '';

    npmDepsHash = hash-npm-deps;
    dontNpmBuild = true;
    doCheck = true;
    checkPhase = "npm run test -- --exclude test/unit/exec-branches.test.ts";
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
