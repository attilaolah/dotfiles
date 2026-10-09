{
  self,
  pkgs,
  system,
  hostname,
  user,
  ...
}: {
  imports = [
    ../home/nix.nix
    ../home/programs/fish.nix
    ../home/users/authorized_keys.nix
    ./homebrew.nix
    ./tls.nix
  ];

  networking.hostName = hostname;

  system = {
    configurationRevision = self.rev or self.dirtyRev or null;
    # $ darwin-rebuild changelog
    stateVersion = 6;

    # Required for Homebrew integration.
    primaryUser = user.username;

    defaults = {
      NSGlobalDomain = {
        # Show the menu bar (disable auto-hide).
        _HIHideMenuBar = false;
        # Keep key-repeat behavior consistent with Hyprland defaults.
        ApplePressAndHoldEnabled = false;
        # MacOS units: 40 -> ~600ms initial delay.
        InitialKeyRepeat = 40;
        # MacOS units are discrete; 3 is a closer default-feel match for 25/s.
        KeyRepeat = 3;

        AppleWindowTabbingMode = "always";

        NSAutomaticCapitalizationEnabled = true;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = true;
        NSAutomaticQuoteSubstitutionEnabled = false;
      };

      CustomUserPreferences = {
        NSGlobalDomain = {
          AppleLocale = "en_CH";
          AppleMenuBarVisibleInFullscreen = true;
          AppleMiniaturizeOnDoubleClick = false;
          AppleActionOnDoubleClick = "Maximize";
        };

        "com.apple.keyboard" = {
          fnState = true;
        };
      };
    };
  };

  users.users."${user.username}" = {
    home = "/Users/${user.username}";
    # NOTE: This doesn't seem to take effect, however, the shell can still be set manually.
    # This requires the shell to be registered in /etc/shells (see environment.shells below).
    # $ chsh -s /run/current-system/sw/bin/fish
    shell = pkgs.fish;
  };

  nixpkgs.hostPlatform = system;

  environment = {
    # Keep fish in /etc/shells so login-shell changes don't get blocked.
    shells = with pkgs; [fish zsh];

    systemPackages = with pkgs; [
      darktable
      google-chrome
    ];
  };
}
