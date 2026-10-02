{
  config,
  lib,
  pkgs,
  ...
}: let
  tomlFormat = pkgs.formats.toml {};
  toINI = lib.generators.toINI {};
in {
  xdg.configFile = let
    inherit (builtins) readFile replaceStrings toJSON;
    inherit (import ../../../hosts/home/fonts.nix {inherit pkgs;}) fonts;

    fontSize = 16;
    fontFamily = builtins.elemAt fonts.fontconfig.defaultFonts.monospace 0;
  in
    {
      "agent-deck/config.toml".source = tomlFormat.generate "agent-deck-config.toml" (import ./agent_deck/config.toml.nix {inherit lib pkgs;});
      "nvim/lua/autocmds.lua".source = ./nvim/lua/autocmds.lua;
      "nvim/lua/chadrc.lua".source = ./nvim/lua/chadrc.lua;
      "nvim/lua/configs/conform.lua".source = pkgs.replaceVars ./nvim/lua/configs/conform.lua {
        alejandra = lib.getExe pkgs.alejandra;
        black = lib.getExe pkgs.black;
        gofumpt = lib.getExe pkgs.gofumpt;
        ktfmt = lib.getExe pkgs.ktfmt;
        prettier = lib.getExe pkgs.prettier;
        rustfmt = lib.getExe pkgs.rustfmt;
        stylua = lib.getExe pkgs.stylua;
        usort = lib.getExe pkgs.usort;
        zig = lib.getExe pkgs.zig;
      };
      "nvim/lua/configs/lazy.lua".source = ./nvim/lua/configs/lazy.lua;
      "nvim/lua/configs/lspconfig.lua".source = ./nvim/lua/configs/lspconfig.lua;
      "nvim/lua/mappings.lua".source = ./nvim/lua/mappings.lua;
      "nvim/lua/options.lua".source = ./nvim/lua/options.lua;
    }
    // lib.attrsets.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      "ghostty/config".text = import ./ghostty {inherit fontFamily fontSize;};
      "karabiner/karabiner.json".text = toJSON (import ./karabiner);
    }
    // lib.attrsets.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.foot.settings
      "foot/foot.ini".text =
        (toINI {
          main = {
            font = "monospace:size=${toString fontSize}";
            font-size-adjustment = 2;
          };
        })
        # TODO: revert once https://github.com/catppuccin/foot/pull/24 is merged
        + replaceStrings [
          "[colors]"
        ] [
          "[colors-dark]"
        ] (readFile pkgs.catppuccin-foot);

      "davfs.conf".text = ''
        secrets ${config.home.homeDirectory}/.config/davfs.secrets
      '';

      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.wofi.style
      "wofi/style.css".text = import ./wofi {inherit fontFamily fontSize;};
    };
}
