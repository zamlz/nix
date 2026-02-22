{ pkgs, ... }:
pkgs.testers.nixosTest {
  name = "nfs-mount";

  nodes.server = {
    networking.firewall.allowedTCPPorts = [ 2049 ];
    services.nfs.server = {
      enable = true;
      exports = ''
        /export *(rw,fsid=0,sync,no_subtree_check,no_root_squash)
      '';
    };
    systemd.tmpfiles.rules = [ "d /export 0755 root root -" ];
  };

  nodes.client = {
    boot.supportedFilesystems = [ "nfs" ];
  };

  testScript = ''
    start_all()
    server.wait_for_unit("nfs-server.service")
    server.succeed("echo 'hello from nas' > /export/testfile")

    client.wait_for_unit("multi-user.target")

    # Mount NFS share and verify file contents
    client.succeed("mkdir -p /mnt/media")
    client.succeed("mount -t nfs server:/ /mnt/media")
    client.succeed("grep -q 'hello from nas' /mnt/media/testfile")
    client.succeed("umount /mnt/media")
  '';
}
