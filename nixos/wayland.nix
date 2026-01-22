{
  pkgs,
  systemConfig,
  ...
}:
{
  services.displayManager.ly = {
    enable = systemConfig.useGUI;
    settings = {
      animation = "colormix";
      battery_id = "BAT0";
      bigclock = true;
    };
  };
  programs.niri.enable = systemConfig.useGUI;

  # FIXME: Move to home-manager?
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  services.playerctld.enable = true;
}
