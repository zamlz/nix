{
  config,
  pkgs,
  constants,
  firewallUtils,
  ...
}:
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
    # Retention limits prevent the pool from filling up with old snapshots.
    # A full ZFS pool refuses all writes — applications mid-write may corrupt.
    autoSnapshot = {
      enable = true;
      frequent = 4; # 15-minute snapshots, keep 4 (1 hour of coverage)
      hourly = 24; # keep 24 hourly snapshots (1 day)
      daily = 7; # keep 7 daily snapshots (1 week)
      weekly = 4; # keep 4 weekly snapshots (1 month)
      monthly = 6; # keep 6 monthly snapshots (6 months)
    };
    trim.enable = true;
  };

  sops.secrets.zfs-nas-key = { };

  # Imports the encrypted ZFS pool and mounts it after sops has decrypted the key.
  # The pool cannot use boot.zfs.extraPools because that runs before sops secrets
  # are available. Instead, this oneshot service handles the full import/unlock/mount
  # sequence, and the NFS bind mount is ordered after it.
  systemd.services.zfs-nas-mount = {
    description = "Import and mount encrypted ZFS NAS pool";
    after = [ "sops-install-secrets.service" ];
    requires = [ "sops-install-secrets.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.zfs ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      zpool list nas >/dev/null 2>&1 || zpool import -N nas
      if [ "$(zfs get -H -o value keystatus nas)" != "available" ]; then
        zfs load-key -L file://${config.sops.secrets.zfs-nas-key.path} nas
      fi
      if [ "$(zfs get -H -o value mounted nas/media)" != "yes" ]; then
        zfs mount nas/media
      fi
    '';
  };

  # Bind mount the NAS dataset to the NFS export location.
  # Must wait for the ZFS pool to be mounted first.
  fileSystems."/export/nas/media" = {
    device = "/mnt/nas/media";
    options = [
      "bind"
      "nofail"
      "x-systemd.requires=zfs-nas-mount.service"
      "x-systemd.after=zfs-nas-mount.service"
    ];
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
}
