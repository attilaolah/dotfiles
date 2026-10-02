{
  lib,
  pkgs,
  ...
}:
pkgs.writeShellApplication {
  name = "sops-restart";
  runtimeInputs = with pkgs;
    [coreutils gnupg gnused]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [systemd];
  text = ''
    gpg-connect-agent UPDATESTARTUPTTY /bye >/dev/null 2>/dev/null

    key="$(
      gpg --list-secret-keys --with-colons 2>/dev/null |
      sed -n 's/^sec:[^:]*:[^:]*:[^:]*:\([^:]*\):.*/\1/p' |
      head -n1
    )"

    if [ -n "$key" ]; then
      printf '%s\n' sops-restart |
        gpg --local-user "$key" --armor --sign --output /dev/null >/dev/null 2>/dev/null
    fi

    ${
      if pkgs.stdenv.hostPlatform.isDarwin
      then ''launchctl kickstart -k "gui/$(id -u)/org.nix-community.home.sops-nix"''
      else "systemctl --user restart sops-nix.service"
    }
  '';
}
