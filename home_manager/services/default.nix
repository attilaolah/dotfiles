{
  lib,
  pkgs,
  ...
}: {
  imports =
    [
      ./gpg_agent.nix
    ]
    ++ lib.lists.optionals pkgs.stdenv.hostPlatform.isLinux [
      ./hypridle.nix
      ./hyprpaper
      ./swaync.nix
    ];
}
