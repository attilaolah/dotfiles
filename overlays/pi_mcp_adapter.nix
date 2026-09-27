final: prev: let
  inherit (builtins) elemAt;
  fetchFromGitHubTuple = import ./lib/fetch_from_github_tuple.nix prev;

  github-tags = ["nicobailon/pi-mcp-adapter" "2.38.0"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-NHyfYDtaypPpyebspSzq2OrG6FKiD1WeUlWMNc2kIsg=";
  hash-npm-deps = "sha256-H2q2gNSvnwbd6vOlTJoTOtXwYSCfBHqJq2cxaXNQkVk=";

  version = elemAt github-tags 1;
  src = fetchFromGitHubTuple {
    inherit github-tags hash-src;
    rev = "v${version}";
  };
  npmSrc = prev.runCommand "pi-mcp-adapter-${version}-npm-src" {nativeBuildInputs = [prev.jq];} ''
    cp -r ${src} $out
    chmod -R u+w $out
    cd $out
    jq 'del(.devDependencies["@earendil-works/pi-coding-agent"])' \
      package.json > package.json.tmp
    mv package.json.tmp package.json
    jq 'del(.packages[""].devDependencies["@earendil-works/pi-coding-agent"])
      | .packages |= with_entries(select(.key | startswith("node_modules/@earendil-works/pi-coding-agent") | not))' \
      package-lock.json > package-lock.json.tmp
    mv package-lock.json.tmp package-lock.json
  '';
in {
  pi-mcp-adapter = prev.buildNpmPackage {
    pname = "pi-mcp-adapter";
    inherit version;
    src = npmSrc;

    npmDeps = prev.fetchNpmDeps {
      src = npmSrc;
      hash = hash-npm-deps;
    };
    npmInstallFlags = ["--omit=dev"];
    dontNpmBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/node_modules/pi-mcp-adapter $out/bin
      cp -r . $out/lib/node_modules/pi-mcp-adapter
      makeWrapper ${prev.nodejs}/bin/node $out/bin/pi-mcp-adapter \
        --add-flags "$out/lib/node_modules/pi-mcp-adapter/cli.js"
      runHook postInstall
    '';
  };
}
