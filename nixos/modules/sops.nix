{ self, ... }:
{
  sops = {
    defaultSopsFile = self + /secrets.yaml;
    age.keyFile = "/etc/age/key.txt";

    secrets.user-password.neededForUsers = true;
  };
}
