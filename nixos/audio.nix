{ inputs, lib, config, pkgs, ... }: {

  environment.systemPackages = with pkgs; [ pavucontrol ];

  sound.enable = lib.mkForce false;  # this is really just ALSA
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  # FIXME: Get pipewire working on of these days
  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  #   jack.enable = true;
  # };
}
