{ self, pkgs }:
pkgs.testers.nixosTest {
  name = "firewall";

  nodes.server = {
    imports = [
      (self + /nixos/modules/networking.nix)
      (self + /nixos/modules/firewall.nix)
      (self + /nixos/modules/ssh.nix)
    ];
  };
  nodes.client = { };

  testScript = ''
    server.start()
    client.start()
    server.wait_for_unit("sshd.service")
    server.wait_for_unit("firewall.service")
    client.wait_for_unit("multi-user.target")

    # SSH (port 22) should be reachable
    client.succeed("nc -z -w 5 server 22")

    # Ports that are not explicitly opened should be blocked
    client.fail("nc -z -w 5 server 8080")
    client.fail("nc -z -w 5 server 2049")
    client.fail("nc -z -w 5 server 443")
  '';
}
