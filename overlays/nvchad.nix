final: prev: let
  inherit (builtins) elemAt;

  git-refs = ["https://github.com/NvChad/NvChad.git" "v2.5" "262f103d3cbe22da7f352c9e01306cf5a34fd8a1"];
  hash-src = "sha256-HVnS+W4laBFrQV8w99FQx50V1l6NwE9XXuggq6JPo6U=";

  rev = elemAt git-refs 2;
  gitHubRepo = prev.lib.splitString "/" (prev.lib.removeSuffix ".git" (prev.lib.removePrefix "https://github.com/" (elemAt git-refs 0)));

  nvchad = prev.vimUtils.buildVimPlugin {
    pname = "nvchad";
    version = "${prev.lib.removePrefix "v" (elemAt git-refs 1)}-unstable+rev=${builtins.substring 0 7 rev}";
    # NvChad requires its user-supplied `chadrc` during module loading, so the generic isolated Neovim require check
    # cannot exercise this plugin.
    doCheck = false;
    src = prev.fetchFromGitHub {
      inherit rev;
      owner = elemAt gitHubRepo 0;
      repo = elemAt gitHubRepo 1;
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
