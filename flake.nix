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
    }@inputs:
    let
      constants = import ./lib/constants.nix;
      builders = import ./lib/builders.nix {
        inherit nixpkgs;
        inherit home-manager;
        inherit nixvim;
        inherit inputs;
        inherit constants;
      };

      inherit (builders) nixosSystemBuilder homeManagerBuilder;
    in
    {
      nixosConfigurations = {
        # Personal Desktop
        solaris = nixosSystemBuilder {
          hostConfigPath = ./hosts/solaris/configuration.nix;
          fontScale = 2.0;
        };

        # Personal Laptop (thinkpad-p14s)
        xynthar = nixosSystemBuilder {
          hostConfigPath = ./hosts/xynthar/configuration.nix;
        };

        # Home Server
        yggdrasil = nixosSystemBuilder {
          # FIXME: host configuration file needs to understand that GUI is not used
          hostConfigPath = ./hosts/yggdrasil/configuration.nix;
          useGUI = false;
        };

        # NAS
        alexandria = nixosSystemBuilder {
          # FIXME: host configuration file needs to understand that GUI is not used
          hostConfigPath = ./hosts/alexandria/configuration.nix;
          useGUI = false;
        };
      };

      # Standalone home manager setup for non-NixOS installations
      homeConfigurations."generic-linux" = homeManagerBuilder {
        homeConfigPath = ./hosts/generic-linux/home.nix;
        useGUI = false;
      };
    };
}
