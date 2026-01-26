{
  pkgs,
  ...
}:
{
  imports = [
    ./foot.nix
    ./niri.nix
    ./swaylock.nix
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    # hyprlax
    swaybg
    xwayland-satellite
    # noctalia-shell # not in current flake revision
  ];

  services.playerctld.enable = true;
}
