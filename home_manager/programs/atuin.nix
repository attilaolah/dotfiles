{
  programs.atuin = {
    enable = true;
    daemon.enable = true;
    enableFishIntegration = true;
    flags = ["--disable-up-arrow"];
    settings = {
      style = "full";
      invert = true;
      enter_accept = true;
      workspaces = true;
      sync.records = true;
      output.enabled = true;
      threads.capture = true;
      theme.name = "catppuccin-mocha-mauve";
    };
  };
}
