{
  description = "zamlz's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixvim}@inputs: {

    # NixOS Configuration Entrypoint
    # ( available through `nixos-rebuild switch --flake .#${hostname}` )

    nixosConfigurations = {
      NAVI-CoplandOS = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
	modules = [ ./hosts/navi.nix ];
      };
    };

    # HomeManager Configuration Entrypoint
    # ( available through `home-manager switch --flake .#${username}` )

    homeConfigurations = {
      zamlz = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
	extraSpecialArgs = { inherit inputs; };
	modules = [ 
          ./users/zamlz
	  nixvim.homeManagerModules.nixvim
	];
      };
    };
  };
}
