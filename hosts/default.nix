# Single source of truth for all hosts.
# Used by nixosConfigurations and homeConfigurations in flake.nix.
{
  # NixOS hosts (full system + home-manager)
  nixos = {
    solaris = {
      hostConfigPath = ./solaris/configuration.nix;
      homeConfigPath = ./solaris/home.nix;
    };
    xynthar = {
      hostConfigPath = ./xynthar/configuration.nix;
      homeConfigPath = ./xynthar/home.nix;
    };
    yggdrasil = {
      hostConfigPath = ./yggdrasil/configuration.nix;
      homeConfigPath = ./yggdrasil/home.nix;
    };
    alexandria = {
      hostConfigPath = ./alexandria/configuration.nix;
      homeConfigPath = ./alexandria/home.nix;
    };
  };

  # Home-manager only (non-NixOS systems)
  home-manager = {
    generic-cli = {
      homeConfigPath = ./generic-cli/home.nix;
    };
    generic-desktop = {
      homeConfigPath = ./generic-desktop/home.nix;
    };
  };
}
