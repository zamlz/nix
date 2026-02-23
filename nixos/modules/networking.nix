_: {
  # NOTE: hostname will be defined in the `/host` specific file!

  networking = {
    firewall.enable = true;
    networkmanager = {
      enable = true;
      # FIXME: Get a router and have that use yggdrasil as the DNS server
      insertNameservers = [
        "10.69.8.3" # yggdrasil (blocky)
        "1.1.1.1" # cloudflare fallback
      ];
    };
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}
