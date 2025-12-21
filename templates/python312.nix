{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              python312Full
              python312Packages.flake8
              python312Packages.ipdb
              python312Packages.ipython
              python312Packages.mypy
              python312Packages.pytest
              python312Packages.tox
              zsh
            ];
            shellHook = ''
              exec zsh
            '';
          };
        }
      );
    };
}
