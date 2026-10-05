{pkgs}: let
  # NvChad's automatic module discovery cannot run without a chadrc.  The
  # purpose-built check below supplies one, so avoid that isolated check while
  # retaining the overlay's empty nvimRequireCheck declaration.
  nvchad = pkgs.vimPlugins.nvchad.overrideAttrs (_: {doCheck = false;});
in
  pkgs.runCommand "nvchad" {
    nativeBuildInputs = [
      pkgs.git
      pkgs.neovim
    ];
  } ''
    export HOME="$TMPDIR/home"
    export XDG_CONFIG_HOME="$TMPDIR/config"
    mkdir -p "$HOME" "$XDG_CONFIG_HOME/nvim/lua"
    cp ${../home_manager/xdg/config_file/nvim/lua/chadrc.lua} "$XDG_CONFIG_HOME/nvim/lua/chadrc.lua"

    ${pkgs.neovim}/bin/nvim --clean --headless \
      --cmd "lua vim.opt.rtp:prepend({[[$XDG_CONFIG_HOME/nvim]], [[${pkgs.vimPlugins.gitsigns-nvim}]], [[${pkgs.vimPlugins.luasnip}]], [[${pkgs.vimPlugins.mason-nvim}]], [[${pkgs.vimPlugins.nvim-cmp}]], [[${pkgs.vimPlugins.nvim-lspconfig}]], [[${pkgs.vimPlugins.telescope-nvim}]], [[${pkgs.vimPlugins.nvim-treesitter}]], [[${pkgs.vimPlugins.nvchad-ui}]], [[${pkgs.vimPlugins.base46}]], [[${nvchad}]]})" \
      '+lua require("nvchad")' \
      '+qa'

    touch "$out"
  ''
