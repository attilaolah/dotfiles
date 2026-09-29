{user, ...}: {
  nix.settings = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];

    trusted-users = [user.username];
    extra-sandbox-paths = [
      "/var/cache/ccache"
    ];
    extra-substituters = [
      "https://devenv.cachix.org" # devenv.sh
      "https://nixpkgs-python.cachix.org" # devenv.sh python
    ];
    trusted-public-keys = [
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
    ];
  };
}
