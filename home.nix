{ config, pkgs, ... }:

{
  home.username = "atl";
  home.homeDirectory = "/home/atl";
  home.stateVersion = "22.11";

  home.packages = with pkgs; [
    # Shell & multiplexer:
    fish
    tmux
    # Editor:
    neovim
    # Development environment:
    git
  ];

  home.file = {
    ".tmux.conf".source = ./src/_.tmux.conf;
  };

  home.sessionVariables = {
    SHELL = "${pkgs.fish}/bin/fish";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.fish = {
    enable = true;
    # You can add additional fish configurations here. For example:
    # interactiveShellInit = "alias ll='ls -la'";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
