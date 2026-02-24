_: {
  services.openssh = {
    enable = true;
    openFirewall = true; # SSH is open from anywhere
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      MaxAuthTries = 3;
    };
  };
}
