final: prev: let
  github-tags = ["SonarSource/sonarqube-mcp-server" "1.18.1.2664"];
  hash-src = "sha256-IfNnxJWjumoyzQfOnemKK7S49nZZwNlH3qkoZkEMHbM=";
  version = builtins.elemAt github-tags 1;
in {
  sonarqube-mcp-server = prev.stdenvNoCC.mkDerivation {
    pname = "sonarqube-mcp-server";
    inherit version;

    src = prev.fetchurl {
      url = "https://binaries.sonarsource.com/Distribution/sonarqube-mcp-server/sonarqube-mcp-server-${version}.jar";
      hash = hash-src;
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      install -Dm644 $src $out/libexec/sonarqube-mcp-server.jar
      mkdir -p $out/bin
      cat > $out/bin/sonarqube-mcp-server <<EOF
      #!${prev.runtimeShell}
      set -eu
      export STORAGE_PATH="\''${STORAGE_PATH:-\''${XDG_STATE_HOME:-\$HOME/.local/state}/sonarqube-mcp-server}"
      mkdir -p "\$STORAGE_PATH"
      exec ${prev.jdk21_headless}/bin/java -jar $out/libexec/sonarqube-mcp-server.jar "\$@"
      EOF
      chmod +x $out/bin/sonarqube-mcp-server

      runHook postInstall
    '';

    meta = {
      description = "MCP server for SonarQube";
      homepage = "https://github.com/SonarSource/sonarqube-mcp-server";
      license = prev.lib.licenses.unfreeRedistributable;
      mainProgram = "sonarqube-mcp-server";
    };
  };
}
