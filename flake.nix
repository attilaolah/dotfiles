{
  description = "NixOS flakes for attilaolah's personal computers.";

  inputs = {
    # Nix packages
    nixpkgs.url = "nixpkgs/nixos-unstable";

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
      url = "github:anomalyco/opencode/v2.0.24";
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
    flake-parts.lib.mkFlake {inherit inputs;} ({...}: let
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

        platform = system: builtins.elemAt (lib.splitString "-" system) 1;
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

        mkConfigs = generator: os: platform:
          lib.mapAttrs' (
            name: value: {
              name = value.hostname or name;
              value = generator.lib."${os}System" {
                inherit (value) system;
                modules = [
                  {
                    nixpkgs = {
                      inherit overlays;
                      config = (value.nixpkgs.config or {}) // unfree;
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
              };
            }
          ) (platformHosts platform);
      in {
        nixosConfigurations = mkConfigs nixpkgs "nixos" "linux";
        darwinConfigurations = mkConfigs nix-darwin "darwin" "darwin";

        # Expose the home-manager configurations directly.
        # This allows one to apply only the home-manager config without switching the system config by running:
        # home-manager switch --flake .#hostname (e.g. --flake .#home)
        homeConfigurations =
          lib.mapAttrs' (name: host: {
            name = host.hostName or host.hostname or name;
            value = home-manager.lib.homeManagerConfiguration {
              pkgs = import nixpkgs {
                inherit overlays;
                inherit (host) system;
                config = (host.nixpkgs.config or {}) // unfree;
              };
              modules = [
                inputs.sops-nix.homeManagerModules.sops
                ./home_manager/home.nix
              ];
              extraSpecialArgs = specialArgs host;
            };
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
          pkgs = import nixpkgs {
            inherit system overlays;
            config = unfree;
          };
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
