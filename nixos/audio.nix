{
  pkgs,
  ...
}:
{
  users.extraGroups.audio.members = [ "amlesh" ];

  environment.systemPackages = with pkgs; [ pavucontrol ];

  services = {
    pulseaudio = {
      enable = true;
      support32Bit = true;
    };

    # FIXME: Get pipewire working on of these days.
    # We also need to force it off because "something" is trying to use it
    pipewire.enable = false;
  };
}
