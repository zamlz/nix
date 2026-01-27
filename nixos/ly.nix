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

  # FIXME: Kinda hacky, but this line is needed'
  # to allow ly to see niri. My home-manager installs
  # one too though.
  programs.niri.enable = systemConfig.useGUI;

  # FIXME: Move to home-manager?
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}
