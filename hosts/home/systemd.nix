{
  config,
  pkgs,
  ...
}: {
  systemd = let
    nodes = map toString [
      11
      16
      17
      18
      19
    ];
    where = id: "/mnt/locker/${id}";
  in {
    mounts =
      map (id: {
        type = "nfs";
        what = "10.8.0.${id}:/mnt/nfs";
        where = where id;
        mountConfig.Options = "noatime";
      })
      nodes;
    automounts =
      map (id: {
        where = where id;
        wantedBy = ["multi-user.target"];
        automountConfig.TimeoutIdleSec = "120";
      })
      nodes;

    # Fix nixos-rebuild hanging, until this issue is resolved:
    # https://github.com/NixOS/nixpkgs/issues/180175#issuecomment-1658731959
    services.NetworkManager-wait-online.serviceConfig.ExecStart = ["" "${pkgs.networkmanager}/bin/nm-online -q"];

    tmpfiles.rules = [
      "d ${config.programs.ccache.cacheDir} 2770 root nixbld - -"
    ];
  };
}
