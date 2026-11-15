{
  config,
  pkgs,
  user,
  ...
}: let
  inherit (builtins) attrNames;

  filterGroups = attrs: attrNames (pkgs.lib.filterAttrs (_: v: v) attrs);
in {
  imports = [
    ./authorized_keys.nix
  ];

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.fish;

    # Generate a password using:
    # nix-shell --run "mkpasswd -m SHA-512 -s" -p mkpasswd
    users = {
      root.initialHashedPassword = (
        "$6$chB8XnZbQno6p5Zp$IE6xp/WGQYYwZGgAkQE9juhofD./R2ITPryZftBellWbeRKUtGBjBGOER6g9Qym"
        + ".oDiMpkPc7OFOE4fxAV.fd/"
      );

      "${user.username}" = {
        isNormalUser = true;
        description = user.fullname;
        initialHashedPassword =
          "$6$SI1H.i.JWUuxp0fV$isfHYRqlDVGmtxPA/wmz7aTSA9Ifs7HSRcAiwxBwoCZmDOx7hgn"
          + "/NlvucF33NqNZp0tABWv3HUHlZxYJSh7NH.";
        group = user.username;
        extraGroups = with config;
          filterGroups {
            wheel = true; # for sudo
            input = true; # for /dev/input/* access
            nfsadmin = true; # homelab direct nfs access
            scanner = hardware.sane.enable;
            lp = services.printing.enable;
            media = true;
            docker = virtualisation.docker.enable;
            podman = virtualisation.podman.enable;
            wireshark = programs.wireshark.enable;
          };
      };
    };

    groups = {
      ${user.username} = {};
      nfsadmin.gid = 2049;
    };
  };
}
