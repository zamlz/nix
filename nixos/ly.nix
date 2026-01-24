{
  pkgs,
  systemConfig,
  ...
}:
{
  services.displayManager.ly = {
    enable = systemConfig.useGUI;
    x11Support = false;
    settings = {
      animation = "colormix";
      battery_id = "BAT0";
      bigclock = true;
      clear_password = true;
    };
  };

  # FIXME: Move to home-manager?
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}
