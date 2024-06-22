{ inputs, lib, config, pkgs, ... }: {

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    earlySetup = true;
    #font = "${pkgs.terminus_font}/share/consolefonts/ter-128n.psf.gz";
    font = "${pkgs.terminus_font}/share/consolefonts/ter-118n.psf.gz";
    packages = with pkgs; [ terminus_font ];
    keyMap = "us";
  };

  environment = {
    systemPackages = with pkgs; [ curl git vim ];
  };

  hardware.graphics.enable = true;

  programs.zsh.enable = true;

  # This enables documentation at a system level, but we still need to
  # apply the same settings in home-manager
  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    man = {
      enable = true;
      generateCaches = true;
      man-db.enable = true;
    };
    nixos.enable = true;
  };
}
