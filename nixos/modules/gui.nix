{
  pkgs,
  systemConfig,
  ...
}:
{
  hardware.graphics.enable = true;

  services = {
    libinput.enable = true;

    xserver = {
      enable = systemConfig.useGUI;
      autoRepeatDelay = 400;
      autoRepeatInterval = 50;
      displayManager.startx.enable = systemConfig.useGUI;
    };

    displayManager.ly = {
      enable = systemConfig.useGUI;
      x11Support = false;
      settings = {
        animation = "colormix";
        battery_id = "BAT0";
        bigclock = true;
        clear_password = true;
      };
    };
  };

  # Note: Unfortunately I have to leave i3lock here because
  # it is the only way it will be properly configured with PAM.
  # Ideally, I could move everything as far into my home-manager
  # config as possible.
  programs.i3lock.enable = systemConfig.useGUI;

  # For same reasons as above, we need to tell PAM to allow swaylock to
  # authenticate
  security.pam.services.swaylock = { };

  # FIXME: Kinda hacky, but this line is needed'
  # to allow ly to see niri. My home-manager installs
  # one too though.
  programs.niri.enable = systemConfig.useGUI;

  # FIXME: Move to home-manager?
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}
