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

    # FIXME: Maybe use this if I really need to use home-manager in arch
    # nixgl.url = "github:nix-community/nixGL";
  };

  outputs =
    {
      # deadnix: skip
      self,
      nixpkgs,
      home-manager,
      nixvim,
    }@inputs:
    let
      builders = import ./lib/builders.nix {
        inherit
          nixpkgs
          home-manager
          nixvim
          inputs
          ;
      };
      inherit (builders) nixosSystemBuilder homeManagerBuilder;

      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      nixosConfigurations = {
        # Personal Desktop
        solaris = nixosSystemBuilder {
          hostConfigPath = ./hosts/solaris/configuration.nix;
          fontScale = 2.0;
        };

        # Personal Laptop (thinkpad-p14s)
        xynthar = nixosSystemBuilder {
          hostConfigPath = ./hosts/xynthar/configuration.nix;
        };

        # Home Server
        yggdrasil = nixosSystemBuilder {
          hostConfigPath = ./hosts/yggdrasil/configuration.nix;
          useGUI = false;
        };

        # NAS
        alexandria = nixosSystemBuilder {
          hostConfigPath = ./hosts/alexandria/configuration.nix;
          useGUI = false;
        };
      };

      # Standalone home manager setup for non-NixOS installations
      homeConfigurations."generic-linux" = homeManagerBuilder {
        homeConfigPath = ./hosts/generic-linux/home.nix;
        useGUI = false;
      };

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # nix rebuild wrapper
              nh
              # Nix formatting and linting
              nixfmt-rfc-style
              statix
              deadnix
              # Custom test function
              (writeShellScriptBin "test" ''
                echo "Running nixfmt..."
                nixfmt --check ./**/*.nix
                echo "Running statix..."
                statix check
                echo "Running deadnix..."
                deadnix
                echo "Checking the flake"
                nix flake check --show-trace
                echo "✓ All checks complete!"
              '')
            ];
          };
        }
      );
    };
}
