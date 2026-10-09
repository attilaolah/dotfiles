{lib, ...}: {
  services.caddy = {
    enable = true;

    virtualHosts =
      lib.mapAttrs' (host: port: {
        name = "${host}.app.localhost";
        value.extraConfig = let
          dst = "localhost:${toString port}";
        in ''
          tls /var/lib/tls/crt.pem /var/lib/tls/key.pem
          reverse_proxy ${dst} {
            header_up Host "${dst}"
            header_up origin "http://${dst}"
          }
        '';
      }) {
        headroom = 8787;
        codebase-memory = 9749;
      };
  };

  # The key is root:tls and is not readable by the primary user.
  # Grant the dedicated Caddy service account access without relaxing that protection.
  users.groups.tls.members = lib.mkAfter ["caddy"];
}
