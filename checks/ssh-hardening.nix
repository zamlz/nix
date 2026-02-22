{ self, pkgs }:
pkgs.testers.nixosTest {
  name = "ssh-hardening";

  nodes.server = {
    imports = [
      (self + /nixos/modules/networking.nix)
      (self + /nixos/modules/fail2ban.nix)
    ];
  };
  nodes.client = { };

  testScript = ''
    server.start()
    server.wait_for_unit("sshd.service")
    server.wait_for_unit("fail2ban.service")

    # Wait for fail2ban socket before querying
    server.wait_for_file("/run/fail2ban/fail2ban.sock")
    server.succeed("fail2ban-client status sshd")

    # Verify SSH is configured to reject root login
    server.succeed("grep -q 'PermitRootLogin.*no' /etc/ssh/sshd_config")

    # Verify SSH is configured to reject password authentication
    server.succeed("grep -q 'PasswordAuthentication.*no' /etc/ssh/sshd_config")
  '';
}
