{
  pkgs,
  ...
}:
{
  services = {
    pulseaudio = {
      enable = true;
      support32Bit = true;
    };

    # FIXME: Get pipewire working on of these days.
    # We also need to force it off because "something" is trying to use it
    pipewire.enable = false;
  };

  # FIXME: Move to pavucontrol package to home manager
  environment.systemPackages = with pkgs; [ pavucontrol ];
}
