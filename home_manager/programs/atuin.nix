{
  programs.atuin = {
    enable = true;
    daemon.enable = true;
    enableFishIntegration = true;
    flags = ["--disable-up-arrow"];
    settings = {
      dialect = "uk";
      style = "full";
      invert = true;
      enter_accept = true;
      show_numeric_shortcuts = false;
      workspaces = true;
      sync.records = true;
      output.enabled = true;
      stats = {
        common_subcommands = [
          "bun"
          "cargo"
          "clan"
          "devenv"
          "direnv"
          "docker"
          "flux"
          "gh"
          "git"
          "helm"
          "kubectl"
          "nix"
          "nom"
          "npm"
          "podman"
          "ruff"
          "systemctl"
          "task"
          "uv"
          "zig"
        ];
        common_prefix = ["sudo"];
      };
      threads.capture = true;
      theme.name = "catppuccin-mocha-mauve";
    };
  };
}
