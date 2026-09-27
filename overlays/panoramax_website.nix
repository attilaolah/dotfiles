final: prev: let
  inherit (builtins) elemAt;

  gitlab-tags = ["panoramax/server/website" "3.6.1"];
  hash-src = "sha256-k5rUOG/Rr5K5LziLdQL9bpxKEq10zeBi3VS/Pbsjqrw=";
  hash-pnpm-deps = "sha256-tOWq7TghYXAYnPb/ICArgzSkJk070PWT+j+M+T8vAu4=";

  version = elemAt gitlab-tags 1;
  src = prev.fetchFromGitLab {
    owner = "panoramax/server";
    repo = "website";
    rev = version;
    hash = hash-src;
  };
in {
  panoramax-website = prev.stdenv.mkDerivation {
    pname = "panoramax-website";
    inherit version src;

    pnpmDeps = prev.fetchPnpmDeps {
      pname = "panoramax-website";
      inherit version src;
      pnpm = prev.pnpm_10;
      fetcherVersion = 4;
      hash = hash-pnpm-deps;
    };
    nativeBuildInputs = [prev.makeWrapper prev.nodejs_24 prev.pnpm_10 prev.pnpmConfigHook];

    doCheck = true;

    buildPhase = ''
      runHook preBuild
      pnpm build
      runHook postBuild
    '';
    checkPhase = ''
      runHook preCheck
      pnpm test:unit
      runHook postCheck
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/panoramax-website $out/bin
      cp -r admin app dist server.js package.json node_modules $out/lib/panoramax-website/
      makeWrapper ${prev.nodejs_24}/bin/node $out/bin/panoramax-website \
        --add-flags "$out/lib/panoramax-website/server.js"
      runHook postInstall
    '';

    meta = {
      description = "Panoramax website";
      homepage = "https://gitlab.com/panoramax/server/website";
      license = prev.lib.licenses.mit;
      mainProgram = "panoramax-website";
    };
  };
}
