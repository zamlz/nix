_: {
  # NOTE: hostname will be defined in the `/host` specific file!

  networking = {
    firewall = {
      enable = true;
      # Allow all services only from the home LAN subnet.
      # SSH is allowed from anywhere (handled separately below).
      extraCommands = ''
        iptables -I nixos-fw -s 10.69.8.0/24 -j nixos-fw-accept
        iptables -I nixos-fw -p tcp --dport 22 -j nixos-fw-accept
      '';
      extraStopCommands = ''
        iptables -D nixos-fw -s 10.69.8.0/24 -j nixos-fw-accept || true
        iptables -D nixos-fw -p tcp --dport 22 -j nixos-fw-accept || true
      '';
    };
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
