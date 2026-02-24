{
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

    mdutils = {
      url = "github:zamlz/mdutils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";

    slippi = {
      url = "github:lytedev/slippi-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      # deadnix: skip
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      builders = import ./lib/builders.nix {
        inherit
          nixpkgs
          home-manager
          inputs
          self
          ;
      };
      inherit (builders)
        nixosSystemBuilder
        homeManagerBuilder
        ;
      hosts = (import ./hosts).nixos;
      homes = (import ./hosts).home-manager;
      mkDevShell = import ./lib/devshell.nix;
      mkChecks = import ./checks;
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      checks = forAllSystems (
        system:
        mkChecks {
          inherit self;
          pkgs = nixpkgs.legacyPackages.${system};
        }
      );

      devShells = forAllSystems (
        system:
        mkDevShell {
          pkgs = nixpkgs.legacyPackages.${system};
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      homeConfigurations = builtins.mapAttrs (_: homeManagerBuilder) homes;

      nixosConfigurations = builtins.mapAttrs (_: nixosSystemBuilder) hosts;
    };
}
