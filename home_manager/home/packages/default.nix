{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    [
      # GNU tools.
      # Already part of NixOS, but explicitly listed so that Darwin systems would have them too.
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
      betterleaks
      bitbucket-cli
      cargo
      clang_22
      colordiff
      cue
      curl
      devenv
      difftastic
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
      go_latest
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
      prettier
      pv
      pwgen
      pyright
      rar
      rclone
      renovate
      ripgrep
      rsync
      ruff
      rustc
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
      yaml-language-server
      yamllint
      yq-go
      zig
      zip
      zizmor
      zoxide

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
      headroom
      qwen-code

      # Python:
      python315

      # NodeJS
      bun
      deno
      nodejs_latest
      pnpm

      # GUI apps available on both Linux and Darwin.
      darktable
      google-chrome

      (llama-cpp.override {
        cudaSupport = pkgs.config.cudaSupport or false;
        metalSupport = pkgs.stdenv.hostPlatform.isDarwin;
      })
      (import ./sops_restart.nix {inherit lib pkgs;})
    ]
    ++ (with python314Packages; [
      huggingface-hub
      ipython
      jmespath
      polars
    ])
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

      # Other GUI apps:
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
