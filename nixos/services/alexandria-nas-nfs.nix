_: {
  # Mount my nas running on alexandria
  fileSystems."/mnt/media" = {
    device = "10.69.8.4:/media";
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
