{
  # NixOS Configuration Entrypoint
  # ( available through `nixos-rebuild switch --flake .#${hostname}` )

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

  outputs = { self, nixpkgs, home-manager, nixvim }@inputs: let

    # function to build nixos systems
    nixosSystemBuilder = { nixosHostConfigPath, graphicalFontScale }@nixosSystemConfig:
      nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          nixosHostConfigPath
          # makes home manager a module of nixos so it will be deployed with
          # nixos-rebuild switch
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              systemConfig = {
                fontScale = graphicalFontScale;
              };
            };
            home-manager.sharedModules = [nixvim.homeManagerModules.nixvim];
            home-manager.users.zamlz = import ./home/zamlz.nix;
          }
        ];
      };

  in {
    nixosConfigurations = {
      # Personal Desktop
      solaris = nixosSystemBuilder {
        nixosHostConfigPath = ./hosts/solaris.nix;
        graphicalFontScale = 2.0;
      };
      # Personal Laptop
      xynthar = nixosSystemBuilder {
        nixosHostConfigPath = ./hosts/xynthar.nix;
        graphicalFontScale = 1.0;
      };
    };
  };
}
