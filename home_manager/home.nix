{
  config,
  lib,
  pkgs,
  user,
  ...
}: {
  imports =
    [
      ./file
      ./home/packages
      ./programs
      ./secrets/contact.nix
      ./services
      ./xdg/config_file
    ]
    ++ lib.lists.optionals pkgs.stdenv.hostPlatform.isLinux [
      ./gtk.nix
      ./home/files/terminfo.nix
      ./qt.nix
      ./wayland/window_manager/hyprland.nix
    ];

  home =
    {
      inherit (user) username;
      homeDirectory = "/${
        if pkgs.stdenv.hostPlatform.isDarwin
        then "Users"
        else "home"
      }/${user.username}";
      stateVersion = "23.11";

      sessionPath = lib.lists.optionals pkgs.stdenv.hostPlatform.isDarwin [
        "/opt/homebrew/bin"
      ];

      sessionVariables = with config.home;
        lib.attrsets.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          # Use Secretive as the SSH agent on MacOS. It is installed via Homebrew or environment.systemPackages.
          # The GPG-agent based socket can still be used by pointing SSH_AUTH_SOCK to GPG_AGENT_INFO.ssh temporarily.
          SSH_AUTH_SOCK = "${homeDirectory}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
        }
        // lib.attrsets.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          # XDG dirs:
          XDG_DESKTOP_DIR = homeDirectory;
          XDG_DOWNLOAD_DIR = "${homeDirectory}/dl";
          XDG_PICTURES_DIR = "${homeDirectory}/photos";
          XDG_PUBLICSHARE_DIR = "${homeDirectory}/share";
          XDG_VIDEOS_DIR = "${homeDirectory}/videos";
          # XDG_DOCUMENTS_DIR not set
          # XDG_MUSIC_DIR not set
          # XDG_TEMPLATES_DIR not set
        };
    }
    // lib.attrsets.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      pointerCursor = {
        enable = true;
        name = "Adwaita";
        size = 24;
        package = pkgs.adwaita-icon-theme;
        gtk.enable = true;
        x11.enable = true;
      };
    };
}
