{
  nixpkgs,
  home-manager,
  nixvim,
  niri,
  inputs,
}:
let
  constants = import ./constants.nix;
  mkSystemConfig =
    {
      fontScale,
    }:
    {
      inherit fontScale;
    };
  mkExtraSpecialArgs = systemConfig: {
    inherit inputs;
    inherit systemConfig;
    inherit constants;
  };
  mkHomeManagerModule = homeConfigPath: extraSpecialArgs: {
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
      fontScale ? 1.0,
    }:
    let
      systemConfig = mkSystemConfig { inherit fontScale; };
      extraSpecialArgs = mkExtraSpecialArgs systemConfig;
    in
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
        (mkHomeManagerModule homeConfigPath extraSpecialArgs)
      ];
    };

  homeManagerBuilder =
    {
      homeConfigPath,
      fontScale ? 1.0,
      system ? "x86_64-linux",
    }:
    let
      systemConfig = mkSystemConfig { inherit fontScale; };
    in
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
      extraSpecialArgs = mkExtraSpecialArgs systemConfig;
    };
}
