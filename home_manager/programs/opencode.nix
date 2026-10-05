{
  lib,
  pkgs,
  ...
}: let
  cmd = package: [(lib.getExe package)];
  cmd' = package: executable: [(lib.getExe' package executable)];
  vsls = server: cmd' pkgs.vscode-langservers-extracted "vscode-${server}-language-server";
  stdio = ["--stdio"];
in {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs.opencode;
    tui.theme = "catppuccin";
    settings = {
      autoshare = false;
      autoupdate = false;
      plugins = [pkgs.opencode-model-router.plugin];
      lsp = {
        css = {
          command = (vsls "css") ++ stdio;
          extensions = [
            ".css"
            ".less"
            ".scss"
          ];
        };

        gopls = {
          command = cmd pkgs.gopls;
          initialization = {
            analyses.unusedparams = true;
            gofumpt = true;
            staticcheck = true;
            usePlaceholders = true;
          };
        };

        eslint.command = (vsls "eslint") ++ stdio;

        helm-ls = {
          command = (cmd pkgs.helm-ls) ++ ["serve"];
          extensions = [
            ".yaml"
            ".yml"
          ];
          initialization."helm-ls".yamlls.path = lib.getExe pkgs.yaml-language-server;
        };

        html = {
          command = (vsls "html") ++ stdio;
          extensions = [
            ".html"
            ".htm"
          ];
        };

        kotlin-ls.command = cmd pkgs.kotlin-language-server;
        lua-ls.command = cmd pkgs.lua-language-server;

        nixd.command = cmd pkgs.nixd;

        pyright.command = (cmd' pkgs.pyright "pyright-langserver") ++ stdio;
        rust.command = cmd pkgs.rust-analyzer;
        typescript.command = (cmd pkgs.typescript-language-server) ++ stdio;

        yaml-ls = {
          command = (cmd pkgs.yaml-language-server) ++ stdio;
          initialization.yaml.schemas."https://json.schemastore.org/github-workflow.json" = "/.github/workflows/*";
        };

        zls.command = cmd pkgs.zls;
      };
      disabled_providers = [
        "anthropic"
        "gemini"
        "openai"
      ];
    };
  };
}
