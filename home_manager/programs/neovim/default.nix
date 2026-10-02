{
  lib,
  pkgs,
  ...
}: let
  nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (
    parsers:
      with parsers; [
        bash
        c
        cpp
        css
        cue
        diff
        dockerfile
        dot
        fish
        git_config
        git_rebase
        gitcommit
        gitignore
        go
        gomod
        gosum
        gotmpl
        gpg
        helm
        html
        http
        ini
        javascript
        json
        jsonnet
        kotlin
        lua
        markdown
        markdown_inline
        nix
        printf
        promql
        proto
        pug
        python
        ruby
        rust
        sql
        ssh_config
        starlark
        terraform
        textproto
        typescript
        vim
        vimdoc
        xml
        yaml
        zig
      ]
  );
  plugins = with pkgs.vimPlugins; {
    NvChad = nvchad;
    LuaSnip = luasnip;
    base46 = base46;
    cmp-async-path = cmp-async-path;
    cmp-buffer = cmp-buffer;
    cmp-nvim-lsp = cmp-nvim-lsp;
    cmp-nvim-lua = cmp-nvim-lua;
    cmp_luasnip = cmp_luasnip;
    "conform.nvim" = conform-nvim;
    friendly-snippets = friendly-snippets;
    "gitsigns.nvim" = gitsigns-nvim;
    "indent-blankline.nvim" = indent-blankline-nvim;
    "mason.nvim" = mason-nvim;
    menu = nvzone-menu;
    minty = nvzone-minty;
    nvim-autopairs = nvim-autopairs;
    nvim-cmp = nvim-cmp;
    nvim-lspconfig = nvim-lspconfig;
    "nvim-tree.lua" = nvim-tree-lua;
    nvim-treesitter = nvim-treesitter;
    nvim-web-devicons = nvim-web-devicons;
    "plenary.nvim" = plenary-nvim;
    "telescope.nvim" = telescope-nvim;
    ui = nvchad-ui;
    vim-tmux-navigator = vim-tmux-navigator;
    volt = nvzone-volt;
    "which-key.nvim" = which-key-nvim;
  };
in {
  imports = [
    ../../../hosts/home/programs/neovim.nix
  ];
  programs.neovim = {
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      # Required by the Nix-packaged Neovim runtime:
      tree-sitter
    ];
    initLua = builtins.readFile ./init.lua;
    plugins = builtins.attrValues plugins;

    # Enable additional language support in the version installed by home-manager.
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
  };

  xdg.configFile."nvim/lua/nix-plugins.lua".text = ''
    return {
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: plugin: ''["${name}"] = "${plugin}",'') plugins
    )}
    }
  '';
  # Referencing these paths in the generated configuration keeps every grammar
  # package in the Home Manager generation closure.
  xdg.configFile."nvim/lua/nix-treesitter-grammars.lua".text = ''
    return {
    ${lib.concatMapStringsSep "\n" (grammar: ''"${grammar}", '') (nvim-treesitter.dependencies or [])}
    }
  '';
  xdg.configFile."nvim/lua/plugins/init.lua".source = ../../xdg/config_file/nvim/lua/plugins/init.lua;
}
