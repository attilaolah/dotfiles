{
  lib,
  pkgs,
  ...
}: {
  imports =
    [
      ./antigravity_cli.nix
      ./atuin.nix
      ./claude_code.nix
      ./codex.nix
      ./dircolors.nix
      ./direnv.nix
      ./fd.nix
      ./fish
      ./fzf.nix
      ./git.nix
      ./gpg.nix
      ./mcp.nix
      ./neovim
      ./nix_index.nix
      ./opencode.nix
      ./pi_coding_agent.nix
      ./rbw.nix
      ./tealdeer.nix
      ./tmux.nix
      ./uv.nix
    ]
    ++ lib.lists.optionals pkgs.stdenv.hostPlatform.isDarwin [
      ./zsh.nix
    ]
    ++ lib.lists.optionals pkgs.stdenv.hostPlatform.isLinux [
      ./hyprlock
      ./waybar
    ];
}
