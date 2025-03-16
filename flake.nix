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

  outputs = { self, nixpkgs, home-manager, nixvim }@inputs: {

    # NixOS Configuration Entrypoint
    # ( available through `nixos-rebuild switch --flake .#${hostname}` )

    nixosConfigurations = {
      xynthar = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/xynthar.nix
          # makes home manager a module of nixos so it will be deployed with
          # nixos-rebuild switch
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              systemConfig = {
                fontScale = 1.0;
              };
            };
            home-manager.sharedModules = [nixvim.homeManagerModules.nixvim];
            home-manager.users.zamlz = import ./home/zamlz.nix;
          }
        ];
      };

      solaris = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
         ./hosts/solaris.nix
          # makes home manager a module of nixos so it will be deployed with
          # nixos-rebuild switch
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              systemConfig = {
                fontScale = 2.0;
              };
            };
            home-manager.sharedModules = [nixvim.homeManagerModules.nixvim];
            home-manager.users.zamlz = import ./home/zamlz.nix;
          }
        ];
      };
    };
  };
}
