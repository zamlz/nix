{ self, pkgs }:
pkgs.testers.nixosTest {
  name = "clamav";

  nodes.server = {
    imports = [
      (self + /nixos/modules/security.nix)
    ];
  };

  testScript = ''
    server.start()
    server.wait_for_unit("multi-user.target")

    # Verify ClamAV services are configured
    server.succeed("systemctl is-enabled clamav-daemon.service")
    server.succeed("systemctl is-enabled clamav-fangfrisch.timer")

    # Verify ClamAV binaries are available
    server.succeed("which clamd")
    server.succeed("which freshclam")
  '';
}
