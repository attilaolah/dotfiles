{
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = false;
    enableNushellIntegration = false;
    enableZshIntegration = false;
    options = ["--cmd" "cd"];
  };
}
