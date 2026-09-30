final: prev: let
  inherit (builtins) elemAt;

  github-commits = ["NvChad/NvChad" "v2.5" "add44b952d631981614bbb8cfc6f7002f296dfe6"];
  hash-src = "sha256-EuP+/HWJgqwG5LR2rNvtq7mhFkUDs0oyeG6xbbPogC4=";

  githubRepo = prev.lib.splitString "/" (elemAt github-commits 0);
  rev = elemAt github-commits 2;

  nvchad = prev.vimUtils.buildVimPlugin {
    pname = "nvchad";
    version = "${prev.lib.removePrefix "v" (elemAt github-commits 1)}-unstable+rev=${builtins.substring 0 7 rev}";
    # NvChad requires its user-supplied `chadrc` during module loading, so the
    # generic isolated Neovim require check cannot exercise this plugin.
    doCheck = false;
    src = prev.fetchFromGitHub {
      inherit rev;
      owner = elemAt githubRepo 0;
      repo = elemAt githubRepo 1;
      hash = hash-src;
    };
    dependencies = with prev.vimPlugins; [
      gitsigns-nvim
      luasnip
      mason-nvim
      nvim-cmp
      nvim-lspconfig
      telescope-nvim
      nvim-treesitter
      nvchad-ui
    ];
    patches = [
      ./nvchad/treesitter_autostart.patch
    ];
  };
in {
  vimPlugins =
    prev.vimPlugins
    // {
      nvchad = nvchad;
    };
}
