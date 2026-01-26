{
  description = "zamlz's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mdutils = {
      url = "github:zamlz/mdutils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";

    # FIXME: Maybe use this if I really need to use home-manager in arch
    # nixgl.url = "github:nix-community/nixGL";
  };

  outputs =
    {
      # deadnix: skip
      self,
      nixpkgs,
      home-manager,
      nixvim,
      nixos-generators,
      niri,
      ...
    }@inputs:
    let
      builders = import ./lib/builders.nix {
        inherit
          nixpkgs
          home-manager
          nixvim
          nixos-generators
          niri
          inputs
          ;
      };
      inherit (builders) nixosSystemBuilder homeManagerBuilder nixosGeneratorBuilder;
      mkDevShell = import ./lib/devshell.nix;
      mkChecks = import ./lib/checks.nix;
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      checks = forAllSystems (
        system:
        mkChecks {
          inherit self;
          pkgs = nixpkgs.legacyPackages.${system};
        }
      );

      devShells = forAllSystems (
        system:
        mkDevShell {
          pkgs = nixpkgs.legacyPackages.${system};
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      homeConfigurations."generic-linux" = homeManagerBuilder {
        homeConfigPath = ./hosts/generic-linux/home.nix;
        useGUI = false;
      };

      nixosConfigurations = {
        # Personal Desktop
        solaris = nixosSystemBuilder {
          hostConfigPath = ./hosts/solaris/configuration.nix;
          homeConfigPath = ./hosts/solaris/home.nix;
          fontScale = 2.0;
        };

        # Personal Laptop (thinkpad-p14s)
        xynthar = nixosSystemBuilder {
          hostConfigPath = ./hosts/xynthar/configuration.nix;
          homeConfigPath = ./hosts/xynthar/home.nix;
        };

        # Home Server
        yggdrasil = nixosSystemBuilder {
          hostConfigPath = ./hosts/yggdrasil/configuration.nix;
          homeConfigPath = ./hosts/yggdrasil/home.nix;
          useGUI = false;
        };

        # NAS
        alexandria = nixosSystemBuilder {
          hostConfigPath = ./hosts/alexandria/configuration.nix;
          homeConfigPath = ./hosts/alexandria/home.nix;
          useGUI = false;
        };
      };

      packages = forAllSystems (system: {
        iso = nixosGeneratorBuilder {
          inherit system;
          hostConfigPath = ./hosts/liveiso/configuration.nix;
          homeConfigPath = ./hosts/liveiso/home.nix;
        };
      });
    };
}
