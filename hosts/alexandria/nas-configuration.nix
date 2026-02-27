{ constants, firewallUtils, ... }:
let
  nfsClientIps = map (host: constants.hostIpAddressMap.${host}) constants.nfsClients;
in
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      port = constants.ports.nfs;
      hosts = constants.nfsClients;
    })
  ];

  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs.devNodes = "/dev/disk/by-id/";
  };

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    trim.enable = true;
  };

  # we bind mount the nas to the export location
  fileSystems."/export/nas/media" = {
    device = "/mnt/nas/media";
    options = [ "bind" ];
  };

  services.nfs.server = {
    enable = true;
    exports =
      let
        mkExportLine =
          path: opts: builtins.concatStringsSep " " (map (ip: "${path} ${ip}(${opts})") nfsClientIps);
      in
      ''
        ${mkExportLine "/export/nas" "rw,fsid=0,sync,no_subtree_check,root_squash"}
        ${mkExportLine "/export/nas/media" "rw,nohide,sync,no_subtree_check,root_squash"}
      '';
  };

  # NOTE: Uncomment this to allow automounting this nas
  # boot.zfs.extraPools = [ "nas" ];
}
