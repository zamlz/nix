{
  pkgs,
  ...
}:
{
  imports = [
    ./foot.nix
    ./niri.nix
    ./swhkd.nix
    ./swaylock.nix
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    # hyprlax
    swaybg
    xwayland-satellite
    wl-clipboard # needed by pass
    # noctalia-shell # not in current flake revision
  ];

  services.playerctld.enable = true;
}
