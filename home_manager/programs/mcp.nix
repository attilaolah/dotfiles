{
  lib,
  pkgs,
  ...
}: {
  programs.mcp = {
    enable = true;

    servers =
      lib.mapAttrs
      (_: server:
        {
          enabled = lib.mkDefault false;
          command = lib.getExe pkgs.gcf-proxy;
          args = [(lib.getExe server.package)] ++ server.args or [];
        }
        // builtins.removeAttrs server ["args" "package"])
      {
        atlassian = {
          description = "Atlassian";
          package = pkgs.mcp-atlassian;
        };
        bitbucket = {
          description = "Bitbucket";
          package = pkgs.bitbucket-mcp;
        };
        codebase_memory = {
          description = "Codebase Memory";
          package = pkgs.codebase-memory-mcp;
          # Relatively cheap and starts quickly.
          enabled = lib.mkDefault true;
        };
        flux_operator = {
          description = "Flux Operator";
          package = pkgs.fluxcd-operator-mcp;
          args = ["serve"];
        };
        headroom = {
          description = "Headroom";
          package = pkgs.headroom-ai;
          args = ["mcp" "serve"];
          # Necessary as the proxy is also on by default.
          enabled = lib.mkDefault true;
        };
        kubernetes = {
          description = "Kubernetes";
          package = pkgs.kubernetes-mcp-server;
        };
        playwright = let
          browser = pkgs.google-chrome;
        in {
          description = "Playwright";
          package = pkgs.playwright-mcp;
          env =
            {
              PLAYWRIGHT_MCP_CAPS = lib.concatStringsSep "," [
                "devtools"
                "network"
                "pdf"
                "storage"
                "testing"
                "vision"
              ];
              PLAYWRIGHT_MCP_ISOLATED = "1";
            }
            // lib.optionalAttrs
            (lib.meta.availableOn pkgs.stdenv.hostPlatform browser)
            {PLAYWRIGHT_MCP_EXECUTABLE_PATH = lib.getExe browser;};
        };
        sonarqube = {
          description = "SonarQube";
          package = pkgs.sonarqube-mcp-server;
        };
        teamcity = {
          description = "TeamCity";
          package = pkgs.teamcity-mcp;
        };
      };
  };
}
