{
  nixpkgs,
  home-manager,
  nixvim,
  niri,
  noctalia,
  inputs,
  self,
}:
let
  constants = import ./constants.nix;
  extraSpecialArgs = { inherit inputs constants self; };
  overlays = [ niri.overlays.niri ];
  sharedModules = [
    nixvim.homeModules.nixvim
    niri.homeModules.niri
    noctalia.homeModules.default
  ];
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
        {
          nixpkgs.overlays = overlays;
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            inherit extraSpecialArgs sharedModules;
            users.amlesh = import homeConfigPath;
          };
          # Required for xdg-desktop-portal when using home-manager
          # with useUserPackages = true
          environment.pathsToLink = [
            "/share/applications"
            "/share/xdg-desktop-portal"
          ];
        }
        hostConfigPath
        home-manager.nixosModules.home-manager
      ];
    };

  homeManagerBuilder =
    {
      homeConfigPath,
      system ? "x86_64-linux",
    }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
      modules = [ homeConfigPath ] ++ sharedModules;
      inherit extraSpecialArgs;
    };
}
