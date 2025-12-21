{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  nixpkgs = {
    config.allowUnfree = true;
  };

  nix = {
    # This will add each flake input as a registry
    # to make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      download-buffer-size = 524288000; # 500 MB
    };

    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 120d";
    };
  };
}
