{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.fish.interactiveShellInit = lib.mkOrder 900 ''
    set fish_greeting
    # TODO: Remove this line once the atuin home-manager module is fixed for fish > 4.3.0
    set -g fish_key_bindings fish_default_key_bindings
    set --global --export GPG_AGENT_INFO (
      ${lib.getExe' config.programs.gpg.package "gpgconf"} --list-dirs agent-socket
    )

    source ${pkgs.catppuccin-fzf}
    set --export FZF_DEFAULT_OPTS "--style=full $FZF_DEFAULT_OPTS"
    set --export ATUIN_THEME_DIR "${pkgs.catppuccin-atuin}"

    ${lib.getExe pkgs.any-nix-shell} fish | source
  '';
}
