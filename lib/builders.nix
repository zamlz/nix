{
  nixpkgs,
  home-manager,
  nixvim,
  niri,
  inputs,
}:
let
  constants = import ./constants.nix;
  extraSpecialArgs = {
    inherit inputs;
    inherit constants;
  };
  mkHomeManagerModule = homeConfigPath: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      inherit extraSpecialArgs;
      sharedModules = [
        nixvim.homeModules.nixvim
        niri.homeModules.niri
      ];
      users.amlesh = import homeConfigPath;
    };
  };
in
{
  nixosSystemBuilder =
    {
      hostConfigPath,
      homeConfigPath,
    }:
    nixpkgs.lib.nixosSystem {
      specialArgs = extraSpecialArgs;
      modules = [
        { nixpkgs.overlays = [ niri.overlays.niri ]; }
        {
          # Required for xdg-desktop-portal when using home-manager
          # with useUserPackages = true
          environment.pathsToLink = [
            "/share/applications"
            "/share/xdg-desktop-portal"
          ];
        }
        hostConfigPath
        home-manager.nixosModules.home-manager
        (mkHomeManagerModule homeConfigPath)
      ];
    };

  homeManagerBuilder =
    {
      homeConfigPath,
      system ? "x86_64-linux",
    }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ niri.overlays.niri ];
      };
      modules = [
        homeConfigPath
        nixvim.homeModules.nixvim
        niri.homeModules.niri
      ];
      inherit extraSpecialArgs;
    };
}
