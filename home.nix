{ config, pkgs, ... }:

{
  home.username = "atl";
  home.homeDirectory = "/home/atl";
  home.stateVersion = "22.11";

  home.packages = with pkgs; [
    # Shell:
    tmux
    # Editor:
    neovim
    # Development environment:
    git
  ];

  home.file = {
    # TODO: Add dotfiles here.
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
