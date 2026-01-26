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
      useGUI,
      fontScale,
    }:
    {
      inherit useGUI;
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
      useGUI ? true,
      fontScale ? 1.0,
    }:
    let
      systemConfig = mkSystemConfig { inherit useGUI fontScale; };
      extraSpecialArgs = mkExtraSpecialArgs systemConfig;
    in
    nixpkgs.lib.nixosSystem {
      specialArgs = extraSpecialArgs;
      modules = [
        { nixpkgs.overlays = [ niri.overlays.niri ]; }
        hostConfigPath
        home-manager.nixosModules.home-manager
        (mkHomeManagerModule homeConfigPath extraSpecialArgs)
      ];
    };

  homeManagerBuilder =
    {
      homeConfigPath,
      useGUI ? false,
      fontScale ? 1.0,
      system ? "x86_64-linux",
    }:
    let
      systemConfig = mkSystemConfig { inherit useGUI fontScale; };
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
