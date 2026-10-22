final: prev: let
  github-tags = ["logseq/logseq" "2.0.2"];
  version = builtins.elemAt github-tags 1;
in {
  logseq = prev.logseq.overrideAttrs (finalAttrs: previousAttrs: {
    inherit version;
    src = prev.fetchFromGitHub {
      owner = "logseq";
      repo = "logseq";
      tag = finalAttrs.version;
      hash = "sha256-rsVjF5LywZoQda9w6mobfnOdbZWo56inz/27jNzUTmo=";
    };

    # The UI package became the workspace root in 2.0.2.
    uiPnpmDeps = null;

    clojureHome = previousAttrs.clojureHome.overrideAttrs {
      outputHash = "sha256-Iv/NFCmpMtkUHSlFAKGdZ4OHzQMMsOM7jTivYSTHgMQ=";
    };

    cliPnpmDeps = previousAttrs.cliPnpmDeps.overrideAttrs {
      outputHash = "sha256-EWSyhc/6oJGMqz1vcfspJiOuQSzqTRS3Oyy/Fpg7Jrk=";
    };

    resourcesPnpmDeps = previousAttrs.resourcesPnpmDeps.overrideAttrs {
      outputHash = "sha256-YDqkZIzs9yAtKJfmbRIoR5G7GQQYve5yRrAa1qYiboc=";
    };

    pnpmDeps = previousAttrs.pnpmDeps.overrideAttrs {
      outputHash = "sha256-xdEEk5N/G0wGHBYvFLe8N2EL66DYUpVpCSHkvvbsIuE=";
    };

    postConfigure = ''
      CI=true pnpmDeps=$pnpmDeps pnpmRoot=. pnpmConfigHook
      pnpmDeps=$cliPnpmDeps pnpmRoot=cli pnpmInstallFlags="--ignore-workspace" pnpmConfigHook
      pnpmDeps=$resourcesPnpmDeps pnpmRoot=resources pnpmInstallFlags="--ignore-workspace" pnpmConfigHook

      substituteInPlace cli/package.json \
        --replace-fail 'opam exec -- dune' 'dune'

      substituteInPlace resources/package.json \
        --replace-fail '"electron-builder ' '"true || electron-builder '

       mkdir static
       mv resources/node_modules static/node_modules
       cp -r node_modules/. static/node_modules

       electron_dist="$(mktemp -d)"
      cp -r ${final.electron_42.dist}/. "$electron_dist"
      chmod -R u+w "$electron_dist"
    '';

    buildPhase = ''
      runHook preBuild

      export npm_config_nodedir=${final.electron_42.headers}
      pnpm run release-electron

      # Keep the bundled CLI at the location used by the 2.0.2 wrapper.
      install -Dm444 static/logseq-cli.js static/cli/dist/index.js
      install -Dm444 static/.agents/skills/logseq-cli/SKILL.md \
        static/cli/.agents/skills/logseq-cli/SKILL.md

      pushd static

      pnpm exec electron-builder \
        --dir \
        --config electron-builder.yml \
        -c.electronDist="$electron_dist" \
        -c.electronVersion=${final.electron_42.version} \
        -c.mac.identity=null

      popd

      runHook postBuild
    '';

    # Logseq 2.0.2 moved the packaged CLI entrypoint out of js/.
    installPhase = builtins.replaceStrings
      ["Resources/app.asar/js/logseq-cli.js"]
      ["Resources/app.asar/cli/dist/index.js"]
      previousAttrs.installPhase;
  });
}
