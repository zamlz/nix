_: {
  networking.networkmanager = {
    enable = true;
    # FIXME: Get a router and have that use yggdrasil as the DNS server
    insertNameservers = [
      "10.69.8.3" # yggdrasil (blocky)
      "1.1.1.1" # cloudflare fallback
    ];
  };
}
