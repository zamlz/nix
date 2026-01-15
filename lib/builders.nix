{
  nixpkgs,
  home-manager,
  nixvim,
  nixos-generators,
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
      sharedModules = [ nixvim.homeModules.nixvim ];
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
      };
      modules = [
        homeConfigPath
        nixvim.homeModules.nixvim
      ];
      extraSpecialArgs = mkExtraSpecialArgs systemConfig;
    };

  nixosGeneratorBuilder =
    {
      hostConfigPath,
      homeConfigPath,
      useGUI ? true,
      fontScale ? 1.0,
      format ? "iso",
      system ? "x86_64-linux",
    }:
    let
      systemConfig = mkSystemConfig { inherit useGUI fontScale; };
      extraSpecialArgs = mkExtraSpecialArgs systemConfig;
    in
    nixos-generators.nixosGenerate {
      inherit system format;
      modules = [
        hostConfigPath
        home-manager.nixosModules.home-manager
        (mkHomeManagerModule homeConfigPath extraSpecialArgs)
      ];
      specialArgs = extraSpecialArgs;
    };
}
