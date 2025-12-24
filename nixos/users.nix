{
  pkgs,
  ...
}:
{
  # (Don't forget to set a password with ‘passwd’!)
  users.users.amlesh = {
    isNormalUser = true;
    description = "Amlesh Sivanantham";
    initialPassword = "pleasechangeme";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # generated using: gpg --export-ssh-key <key-id>
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCay4PvvAeYuYcfQhmcFaVAzodepVN3G0GVGyD2GiwC9Bm9gZpdi4ra30EimXDyIllFeYSmFEbvahE3N9X/Xk0zoc6+Ixe0TP6Zvhy+EC0gr3vUBxti5BDQxnJke3XKwJPK1V5s7PND5tW6aPM9x+HnGWz1Szt8sTl/C4lHGPR3iv3r43NoCcab6oRJfkb486S1WiSeX2K5zTOFi8+MkAXiTTDDCMVB7eGxrv2gEPXCgZsvgzRGZVpyl7HYtwWgKdc7jI3awF4bFhqOmx4jZ2fqmAoNlXQlSX0VX6a1EVvUpwS2cKmrD8T+lWFNpAwj5OCYpNxsALIHf6aGZjwK9UVqo3oRllM1uKvgOE7FAjXkYZvT0ZIYf+aZ7oXVmUlrhVJc9Rvl1liWhl8n+s0t4qhbzJDK7RBCVBQlg6dbA3j1I3JMJ08ttRf0ZpvpKPLB9ONls3uYUo4joQ/I0ffY9jATVSzDC00qm/aLQdUop2lcbjr5syf21djspk+kX/1tNJI7rtWXvjFlXJj6nWPejGsiKXxuOtIyzPo3Y0/0USZamQLtu5SRTbTOQDs4cQOQdTCMvvMC9/8ZYFI0qjh6vDgeKfn2dnjiogqmCDBiTkR+oUifZCSTIb2jLNhmH2RcIB5GmawT0lm14q6PLJreseBD5hJpAzasbv0524t60wYhkw== openpgp:0xA7FE5E2D"
    ];
  };
}
