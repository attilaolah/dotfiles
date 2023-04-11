{ config, pkgs, ... }:

{
  home.username = "atl";
  home.homeDirectory = "/home/atl";
  home.stateVersion = "22.11";

  home.packages = with pkgs; [
    # Use NeoVim as the editor.
    neovim
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
