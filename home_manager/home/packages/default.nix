{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    [
      # GNU tools
      coreutils # cp, mv, rm, etc.
      findutils # find
      gawk # awk
      gnused # sed
      procps # watch
      util-linux # cal, etc.

      # CLI utilities:
      age
      any-nix-shell
      bat
      bitbucket-cli
      colordiff
      curl
      devenv
      dig
      exiftool
      expect
      fastfetch
      ffmpeg
      file
      gh
      gitleaks
      glow
      gnumake
      gnupg
      go-task
      gotop
      htop
      jira-cli-go
      jq
      killall
      kubectl
      kubernetes-helm
      libnotify
      mktemp
      nix-output-monitor
      nixpkgs-review
      openssl
      p7zip
      pciutils
      pinentry-tty
      pv
      pwgen
      rar
      rclone
      renovate
      ripgrep
      rsync
      shellcheck
      sops
      subversion
      termshark
      tmux
      tree
      ty
      unzip
      usbutils
      wget
      xkcdpass
      yamllint
      yq-go
      zip
      zoxide

      # NeoVim language servers and runtimes:
      cargo
      clang_22
      cue
      go
      gopls
      helm-ls
      nil
      pyright
      rustc
      rust-analyzer
      zig
      zls

      # Used by MCP servers currently
      yaml-language-server

      # Virtualisation:
      crane
      podman
      podman-compose
      podman-tui
      skopeo

      # AI stuff:
      agent-deck
      bosun
      coderabbit
      headroom-ai
      qwen-code

      # Python, the basics:
      (python314.withPackages (ps:
        with ps; [
          huggingface-hub
          ipython
          jmespath
          polars
        ]))

      # NPM packages:
      # NodeJS runtimes & packages
      bun
      nodejs_26
      pnpm
      typescript-language-server

      (llama-cpp.override {
        cudaSupport = pkgs.config.cudaSupport or false;
        metalSupport = pkgs.stdenv.hostPlatform.isDarwin;
      })
      (import ./restart_sops.nix {inherit lib pkgs;})
    ]
    ++ lib.lists.optionals pkgs.stdenv.hostPlatform.isLinux [
      # Not supported on darwin:
      bubblewrap
      traceroute

      # Using podman-compose on darwin instead.
      docker-compose

      # Theming:
      gsettings-desktop-schemas
      dconf-editor
      glib

      # Browsers:
      google-chrome

      # Other GUI apps:
      darktable
      discord
      foot
      gimp
      inkscape
      pavucontrol
      rawtherapee
      slack
      teams-for-linux
      wireshark

      # Gnome apps:
      cheese
      eog
      file-roller
      nautilus
    ];
}
