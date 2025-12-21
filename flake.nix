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

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixvim,
    }@inputs:
    let
      # function to build nixos systems
      nixosSystemBuilder =
        {
          hostConfigPath,
          useGUI ? true,
          fontScale ? 1.0,
        }@nixosSystemConfig:
        let
          systemConfig = {
            inherit useGUI;
            inherit fontScale;
          };
        in
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit systemConfig;
          };
          modules = [
            hostConfigPath
            # makes home manager a module of nixos so it will be deployed with
            # nixos-rebuild switch
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit inputs;
                  inherit systemConfig;
                };
                sharedModules = [ nixvim.homeModules.nixvim ];
                users.amlesh = import ./home/amlesh.nix;
              };
            }
          ];
        };
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
      # FIXME: Need to inherit the systemConfig attribute set somehow
      homeConfigurations."amlesh" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          config.allowUnfree = true;
        };
        modules = [
          ./home/amlesh.nix
        ];
      };
    };
}
