{
  nixpkgs,
  home-manager,
  nixvim,
  inputs,
  constants,
}:
{
  # Function to build NixOS systems with home-manager integrated
  nixosSystemBuilder =
    {
      hostConfigPath,
      useGUI ? true,
      fontScale ? 1.0,
    }:
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
        inherit constants;
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
              inherit constants;
            };
            sharedModules = [ nixvim.homeModules.nixvim ];
            users.amlesh = import ../home/amlesh.nix;
          };
        }
      ];
    };

  # Function to build standalone home-manager configurations (for non-NixOS systems)
  homeManagerBuilder =
    {
      homeConfigPath,
      useGUI ? true,
      fontScale ? 1.0,
      system ? "x86_64-linux",
    }:
    let
      systemConfig = {
        inherit useGUI;
        inherit fontScale;
      };
    in
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      modules = [
        homeConfigPath
        nixvim.homeModules.nixvim
      ];
      extraSpecialArgs = {
        inherit inputs;
        inherit systemConfig;
        inherit constants;
      };
    };
}
