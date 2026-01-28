{
  pkgs,
  config,
  ...
}:
{
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  # default console font is ugly
  console = {
    earlySetup = true;
    #font = "${pkgs.terminus_font}/share/consolefonts/ter-128n.psf.gz";
    font = "${pkgs.terminus_font}/share/consolefonts/ter-118n.psf.gz";
    packages = with pkgs; [ terminus_font ];
    keyMap = "us";
  };

  environment.etc."issue".text =
    let
      name = config.users.users.amlesh.description;
    in
    ''

        ███    ██ ██ ██   ██  ██████  ███████   Hostname: \n
        ████   ██ ██  ██ ██  ██    ██ ██        Kernel: \s \r (\m)
        ██ ██  ██ ██   ███   ██    ██ ███████   Build: \v
        ██  ██ ██ ██  ██ ██  ██    ██      ██   Date: \d \t
        ██   ████ ██ ██   ██  ██████  ███████   TTY: \l

      Welcome ${name}!

    '';

  environment = {
    systemPackages = with pkgs; [
      # Hardware utils
      pciutils
      usbutils
      # process utils
      htop
      pstree
      # Software utils
      curl
      less
      tree
      zip
      unzip
    ];
  };
}
