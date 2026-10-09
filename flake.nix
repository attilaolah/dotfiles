{
  description = "NixOS flakes for attilaolah's personal computers.";

  inputs = {
    # Nix packages
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";

    nixpkgs-patch-pr-567447 = {
      url = "https://github.com/NixOS/nixpkgs/commit/49ad14a096e9ab4a21cece147e53d3efdc06848c.patch";
      flake = false;
    };
    nixpkgs-patch-pr-567590 = {
      url = "https://github.com/NixOS/nixpkgs/commit/f08a2c8a1c948d795e4e9aefcd20147fbbc18e11.patch";
      flake = false;
    };
    nixpkgs-patch-pr-567590-2 = {
      url = "https://github.com/NixOS/nixpkgs/commit/dd1df322014c5a15c6c494a2d42816aab0637652.patch";
      flake = false;
    };
    nixpkgs-patch-pr-567590-3 = {
      url = "https://github.com/NixOS/nixpkgs/commit/345623679c07a68cc35c18f1d67437503b0c872c.patch";
      flake = false;
    };
    nixpkgs-patch-pr-567590-4 = {
      url = "https://github.com/NixOS/nixpkgs/commit/28fb71b8d9b9f763719c8e18fbd0248dcc506f52.patch";
      flake = false;
    };
    nixpkgs-patch-pr-567590-5 = {
      url = "https://github.com/NixOS/nixpkgs/commit/bbed8a2ad57a3b243dee22cde4938722da00e660.patch";
      flake = false;
    };
    nixpkgs-patch-pr-568773 = {
      url = "https://github.com/NixOS/nixpkgs/commit/f6d284448c9029c0197e79cdf65f31398a0d7995.patch";
      flake = false;
    };
    nixpkgs-patch-pr-569784 = {
      url = "https://github.com/NixOS/nixpkgs/commit/fc8c84a279555a6ce7f4f916bd4a17ffed224c9a.patch";
      flake = false;
    };

    # Nix-Darwin
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home-Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SOPS integration
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake-Parts
    flake-parts.url = "github:hercules-ci/flake-parts";

    # OpenCode upstream overlay
    opencode = {
      url = "github:anomalyco/opencode/v2.0.26";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # DVP layout with compose key
    programmer-dvorak-compose = {
      url = "github:attilaolah/programmer-dvorak-compose/v1.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} ({withSystem, ...}: let
      inherit (nixpkgs) lib;
      overlays =
        [inputs.opencode.overlays.default]
        ++ lib.mapAttrsToList
        (name: _: import (./overlays + "/${name}"))
        overlayFileNames;
      overlayFileNames =
        lib.filterAttrs
        (name: type: type == "regular" && lib.hasSuffix ".nix" name)
        (builtins.readDir ./overlays);
      unfree.allowUnfree = true;
    in {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      imports = [
        (import ./nixpkgs.nix {inherit inputs overlays unfree;})
        inputs.home-manager.flakeModules.home-manager
      ];

      flake = let
        hosts = {
          home = {
            system = "x86_64-linux";
            username = "ao";
            ncores = 20;
            nixpkgs.config = {
              cudaSupport = true;
              # To get the supported capabilities:
              # nvidia-smi --query-gpu=compute_cap --format=csv,noheader
              cudaCapabilities = ["8.6"]; # RTX 3070
              cudaForwardCompat = false;
            };
          };
          work = {
            hostname = "nb1635";
            system = "aarch64-darwin";
            username = "olaa";
            ncores = 10;
          };
        };

        platform = system: (import ./overlays/lib/platform.nix system).platform;
        platformHosts = p:
          lib.filterAttrs
          (_: value: (platform value.system) == p)
          hosts;
        specialArgs = {
          system,
          username,
          ncores,
          ...
        }:
          inputs
          // {
            inherit system ncores;
            user = {
              inherit username;
              fullname = "Attila Oláh";
            };
            platform = platform system;
          };

        mkConfigs = os: platform:
          lib.mapAttrs' (
            name: value: {
              name = value.hostname or name;
              value = withSystem value.system (_:
                inputs.nixpkgs-patcher.lib."${os}System" {
                  inherit (value) system;
                  modules = [
                    {
                      nixpkgs = {
                        config = (value.nixpkgs.config or {}) // unfree;
                        inherit overlays;
                      };
                    }
                    ./hosts/${name}/configuration.nix
                    (lib.optionalAttrs (os == "darwin") {
                      imports = [
                        inputs.programmer-dvorak-compose.darwinModules.default
                      ];
                    })
                    home-manager."${os}Modules".home-manager
                    {
                      home-manager = {
                        backupFileExtension = "bkp";
                        extraSpecialArgs = specialArgs value;
                        sharedModules = [
                          inputs.sops-nix.homeManagerModules.sops
                        ];
                        users.${value.username} = import ./home_manager/home.nix;
                        useGlobalPkgs = true;
                        useUserPackages = true;
                      };
                    }
                  ];
                  specialArgs = specialArgs value;
                });
            }
          ) (platformHosts platform);
      in {
        nixosConfigurations = mkConfigs "nixos" "linux";
        darwinConfigurations = mkConfigs "darwin" "darwin";

        # Expose the home-manager configurations directly.
        # This allows one to apply only the home-manager config without switching the system config by running:
        # home-manager switch --flake .#hostname (e.g. --flake .#home)
        homeConfigurations =
          lib.mapAttrs' (name: host: {
            name = host.hostName or host.hostname or name;
            value = withSystem host.system ({config, ...}:
              home-manager.lib.homeManagerConfiguration {
                pkgs = config._module.args.mkPatchedPkgs (host.nixpkgs.config or {});
                modules = [
                  inputs.sops-nix.homeManagerModules.sops
                  ./home_manager/home.nix
                ];
                extraSpecialArgs = specialArgs host;
              });
          })
          hosts;
      };

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        formatter = pkgs.alejandra;

        packages = let
          packageNames = lib.unique (["opencode"]
            ++ lib.pipe (lib.attrNames overlayFileNames) [
              (map (name: lib.removeSuffix ".nix" name))
              (map (name: lib.replaceStrings ["_"] ["-"] name))
              (lib.filter (name: builtins.hasAttr name pkgs))
            ]);
          exportedPackages = lib.genAttrs packageNames (name: builtins.getAttr name pkgs);
          hashOutputsFor = name: let
            pkg = builtins.getAttr name pkgs;
            srcOutputs = lib.optionalAttrs (pkg ? passthru && pkg.passthru ? sources) (
              lib.mapAttrs'
              (system: source: lib.nameValuePair "${name}-src-${system}" source)
              pkg.passthru.sources
            );
          in
            srcOutputs
            // (lib.optionalAttrs (pkg ? src && lib.isDerivation pkg.src) {"${name}-src" = pkg.src;})
            // (lib.optionalAttrs (pkg ? cargoDeps) {"${name}-cargo-deps" = pkg.cargoDeps;})
            // (lib.optionalAttrs (pkg ? goModules) {"${name}-vendor" = pkg.goModules;})
            // (lib.optionalAttrs (pkg ? npmDeps) {"${name}-npm-deps" = pkg.npmDeps;});
          exportedHashOutputs = lib.foldl' lib.recursiveUpdate {} (map hashOutputsFor packageNames);
        in
          exportedPackages
          // exportedHashOutputs;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go-task
            pkgs.home-manager
            nix-output-monitor
            nvd
            sops
          ];
        };
      };
    });
}
