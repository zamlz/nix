{ constants, ... }:
{
  # Mount the NAS
  fileSystems."/mnt/media" = {
    device = "${constants.hostIpAddressMap.${constants.nasHost}}:/media";
    fsType = "nfs";
    # enable lazy mounting for this share
    options = [
      "x-systemd.automount"
      "noauto"
    ];
  };
  # optional, but ensures rpc-statsd is running for on demand mounting
  boot.supportedFilesystems = [ "nfs" ];
}
