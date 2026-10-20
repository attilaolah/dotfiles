{
  description = "NixOS flakes for attilaolah's personal computers.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode = {
      url = "github:anomalyco/opencode/v2.1.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    programmer-dvorak-compose = {
      url = "github:attilaolah/programmer-dvorak-compose/v1.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # python3Packages.opendal: 0.46.0 -> 0.47.10
    nixpkgs-patch-pr-567447 = {
      url = "https://github.com/NixOS/nixpkgs/commit/49ad14a096e9ab4a21cece147e53d3efdc06848c.patch?full_index=1";
      flake = false;
    };
    # mcp-atlassian: init at 0.23.1
    nixpkgs-patch-pr-567590-1 = {
      url = "https://github.com/NixOS/nixpkgs/commit/6c58d6a4b8f6f8b0b26458035c353b5f377af0b2.patch?full_index=1";
      flake = false;
    };
    nixpkgs-patch-pr-567590-2 = {
      url = "https://github.com/NixOS/nixpkgs/commit/e8c68437d73df443b72afd9220d707b258b8a45c.patch?full_index=1";
      flake = false;
    };
    nixpkgs-patch-pr-567590-3 = {
      url = "https://github.com/NixOS/nixpkgs/commit/539fd7b9ece220a59a6a27751a6f37096972dc8a.patch?full_index=1";
      flake = false;
    };
    nixpkgs-patch-pr-567590-4 = {
      url = "https://github.com/NixOS/nixpkgs/commit/3218158c2ba8dacacaf70c4fe1d7371790e374a7.patch?full_index=1";
      flake = false;
    };
    nixpkgs-patch-pr-567590-5 = {
      url = "https://github.com/NixOS/nixpkgs/commit/9d6ce87ddfb1f4b9f4cd59f0a7aac47927cb43c0.patch?full_index=1";
      flake = false;
    };
    # headroom: init at 0.41.0
    nixpkgs-patch-pr-569784 = {
      url = "https://github.com/NixOS/nixpkgs/commit/bbf61c790b44abe65be9c60665cfb0fa28f25767.patch?full_index=1";
      flake = false;
    };
    # codebase-memory-mcp: 0.11.0 -> 0.12.1
    nixpkgs-patch-pr-574836 = {
      url = "https://github.com/NixOS/nixpkgs/commit/af5ba05b472365262e19f9f3e6b938cf53fecfbe.patch?full_index=1";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    flake-parts,
    opencode,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} ({withSystem, ...}: let
      inherit (nixpkgs) lib;
      overlays =
        [
          opencode.overlays.default
          # Fix OpenCode build error:
          # Cannot find module '../../../script/native-arch' from '/build/source/packages/cli/script/build.ts'
          (final: prev: {opencode = prev.opencode.overrideAttrs (_: {src = opencode;});})
        ]
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
                      nixpkgs.config =
                        (value.nixpkgs.config or {})
                        // {
                          packageOverrides = pkgs: let
                            composed = lib.composeManyExtensions overlays;
                            final = pkgs // composed final pkgs;
                          in
                            composed final pkgs;
                        }
                        // unfree;
                    }
                    ./hosts/${name}/configuration.nix
                    (lib.optionalAttrs (os == "darwin") {
                      imports = [
                        inputs.programmer-dvorak-compose.darwinModules.default
                      ];
                    })
                    home-manager."${os}Modules".home-manager
                    ({pkgs, ...}: {
                      home-manager = {
                        backupFileExtension = "bkp";
                        extraSpecialArgs = specialArgs value // {inherit pkgs;};
                        sharedModules = [
                          inputs.sops-nix.homeManagerModules.sops
                        ];
                        users.${value.username} = import ./home_manager/home.nix;
                        useGlobalPkgs = true;
                        useUserPackages = true;
                      };
                    })
                  ];
                  specialArgs = specialArgs value;
                });
            }
          ) (platformHosts platform);
      in {
        nixosConfigurations = mkConfigs "nixos" "linux";
        darwinConfigurations = mkConfigs "darwin" "mac";

        # Expose the home-manager configurations directly.
        # This allows one to apply only the home-manager config without switching the system config by running:
        # home-manager switch --flake .#hostname (e.g. --flake .#home)
        homeConfigurations =
          lib.mapAttrs' (name: host: {
            name = host.hostname or name;
            value = withSystem host.system ({config, ...}: let
              pkgs = config._module.args.build (host.nixpkgs.config or {});
            in
              home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [
                  inputs.sops-nix.homeManagerModules.sops
                  ./home_manager/home.nix
                ];
                extraSpecialArgs = specialArgs host // {inherit pkgs;};
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
