{
  nixpkgs,
  home-manager,
  inputs,
  self,
  ...
}:
let
  constants = import ./constants.nix;
  firewallUtils = import ./utils/firewall.nix;
  extraSpecialArgs = {
    inherit
      inputs
      constants
      firewallUtils
      self
      ;
  };
  overlays = import ./overlays.nix { inherit inputs self; };

  # Shared modules used by nixosSystemBuilder
  mkModules =
    { hostConfigPath, homeConfigPath }:
    [
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
in
{
  nixosSystemBuilder =
    {
      hostConfigPath,
      homeConfigPath,
      ...
    }:
    nixpkgs.lib.nixosSystem {
      specialArgs = extraSpecialArgs;
      modules = mkModules { inherit hostConfigPath homeConfigPath; };
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
