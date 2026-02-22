{
  nixpkgs,
  home-manager,
  inputs,
  self,
  ...
}:
let
  constants = import ./constants.nix;
  extraSpecialArgs = { inherit inputs constants self; };
  overlays = import ./overlays.nix { inherit inputs self; };
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
            inherit extraSpecialArgs;
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
        inputs.sops-nix.nixosModules.sops
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
      modules = [ homeConfigPath ];
      inherit extraSpecialArgs;
    };
}
