{ pkgs }:
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
        nix flake check --show-trace --all-systems
        echo "✓ All checks complete!"
      '')
    ];
  };
}
