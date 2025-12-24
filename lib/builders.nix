{
  nixpkgs,
  home-manager,
  nixvim,
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
    in
    nixpkgs.lib.nixosSystem {
      specialArgs = mkExtraSpecialArgs systemConfig;
      modules = [
        hostConfigPath
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = mkExtraSpecialArgs systemConfig;
            sharedModules = [ nixvim.homeModules.nixvim ];
            users.amlesh = import homeConfigPath;
          };
        }
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
      };
      modules = [
        homeConfigPath
        nixvim.homeModules.nixvim
      ];
      extraSpecialArgs = mkExtraSpecialArgs systemConfig;
    };
}
