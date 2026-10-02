{
  imports = [
    ./fish.nix
    ./neovim.nix
  ];
  programs = let
    on.enable = true;
  in {
    # Window manager:
    hyprland = on;
    hyprlock = on;

    # Misc. utilities:
    openvpn3 = on;
    wireshark = on;
  };
}
