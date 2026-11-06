{
  config,
  pkgs,
  ...
}: let
  theme = {
    name = "WhiteSur-Dark-grey";
    package = pkgs.whitesur-gtk-theme.override {
      themeVariants = ["grey"];
      colorVariants = ["dark"];
    };
  };
  extraConfig.gtk-application-prefer-dark-theme = 1;
in {
  gtk = {
    inherit theme;

    enable = true;

    # Papirus icon theme with Catppuccin folder colours.
    # To repaint the folders, change `flavor` (latte/frappe/macchiato/mocha) or `accent`
    # (blue/flamingo/green/lavender/maroon/mauve/peach/pink/red/ rosewater/sapphire/sky/teal/yellow) and rebuild.
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "mauve";
      };
    };
    cursorTheme = with config.home.pointerCursor; {
      inherit name size;
    };

    gtk3 = {inherit extraConfig;};
    gtk4 = {inherit theme extraConfig;};
  };
}
