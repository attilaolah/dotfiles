{
  config,
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
          # Product-specific MCP servers are disabled by default.
          # Only enable MCPs that are useful or necessary in most sessions.
          enabled = lib.mkDefault false;
        }
        // lib.optionalAttrs (server ? package) {
          command = lib.getExe pkgs.gcf-proxy;
          args = [(lib.getExe server.package)] ++ server.args or [];
        }
        // builtins.removeAttrs server ["args" "package"])
      {
        atlassian = {
          description = "Atlassian";
          package = pkgs.mcp-atlassian;
        };
        atuin = {
          description = "Atuin";
          package = config.programs.atuin.package;
          args = ["mcp"];
          enabled = lib.mkDefault true;
        };
        bitbucket = {
          description = "Bitbucket";
          package = pkgs.bitbucket-mcp;
        };
        codebase_memory = {
          description = "Codebase Memory";
          package = pkgs.codebase-memory-mcp;
          enabled = lib.mkDefault true;
        };
        context7 = {
          description = "Context7";
          package = pkgs.context7-mcp;
          enabled = lib.mkDefault true;
        };
        flux_operator = {
          description = "Flux Operator";
          package = pkgs.fluxcd-operator-mcp;
          args = ["serve"];
        };
        github = {
          description = "GitHub";
          url = "https://api.githubcopilot.com/mcp/";
        };
        headroom = {
          description = "Headroom";
          package = pkgs.headroom;
          args = ["mcp" "serve"];
          # Necessary as the proxy is also on by default.
          enabled = lib.mkDefault true;
        };
        kubernetes = {
          description = "Kubernetes";
          package = pkgs.kubernetes-mcp-server;
        };
        nixos = {
          description = "NixOS";
          package = pkgs.mcp-nixos;
          enabled = lib.mkDefault true;
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
        rea = {
          description = "Reverse Engineer Anything";
          package = pkgs.rea;
          args = ["mcp"];
          env = {
            inherit (config.home.sessionVariables) GHIDRA_INSTALL_DIR JAVA_HOME;
          };
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
