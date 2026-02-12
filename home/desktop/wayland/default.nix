{
  pkgs,
  ...
}:
{
  imports = [
    ./niri.nix
    ./swaylock.nix
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    # hyprlax
    swaybg
    xwayland-satellite
    wl-clipboard # needed by pass
  ];

  services.playerctld.enable = true;
}
