{ constants, ... }:
{
  networking.networkmanager = {
    enable = true;
    # FIXME: Get a router and have that use yggdrasil as the DNS server
    insertNameservers = [
      constants.hostIpAddressMap.${constants.services.blocky.host} # blocky DNS
      "1.1.1.1" # cloudflare fallback
    ];
  };
}
