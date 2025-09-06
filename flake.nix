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

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
  } @ inputs: let
    # function to build nixos systems
    nixosSystemBuilder = {
      hostConfigPath,
      useGUI ? true,
      fontScale ? 1.0,
    } @ nixosSystemConfig: let
      systemConfig = {
        useGUI = useGUI;
        fontScale = fontScale;
      };
    in
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          systemConfig = systemConfig;
        };
        modules = [
          hostConfigPath
          # makes home manager a module of nixos so it will be deployed with
          # nixos-rebuild switch
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              systemConfig = systemConfig;
            };
            home-manager.sharedModules = [nixvim.homeModules.nixvim];
            home-manager.users.amlesh = import ./home/amlesh.nix;
          }
        ];
      };
  in {
    nixosConfigurations = {
      # Personal Desktop
      solaris = nixosSystemBuilder {
        hostConfigPath = ./hosts/solaris.nix;
        fontScale = 2.0;
      };

      # Personal Laptop (thinkpad-25a)
      xanadu = nixosSystemBuilder {
        hostConfigPath = ./hosts/xanadu.nix;
      };

      # Personal Laptop (thinkpad-p14s)
      xynthar = nixosSystemBuilder {
        hostConfigPath = ./hosts/xynthar.nix;
      };

      # Home Server
      yggdrasil = nixosSystemBuilder {
        # FIXME: host configuration file needs to understand that GUI is not used
        hostConfigPath = ./hosts/yggdrasil.nix;
        useGUI = false;
      };

      # NAS
      alexandria = nixosSystemBuilder {
        # FIXME: host configuration file needs to understand that GUI is not used
        hostConfigPath = ./hosts/alexandria.nix;
        useGUI = false;
      };
    };
  };
}
