# Booklore — self-hosted digital book library.
# Runs as an OCI container on yggdrasil behind Caddy, with a MariaDB sidecar.
# Books are mounted read-only from the Alexandria NAS via NFS (/mnt/media/Books).
#
# Debugging:
#   docker logs booklore
#   docker logs booklore-mariadb
#   curl http://localhost:6060
#   Access https://booklore.lab.zamlz.org in a browser
{
  config,
  constants,
  firewallUtils,
  ...
}:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.booklore) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  sops = {
    secrets = {
      booklore-db-password = { };
      booklore-db-root-password = { };
    };
    templates.booklore-env = {
      content = ''
        DATABASE_URL=jdbc:mariadb://127.0.0.1:3306/booklore
        DATABASE_USERNAME=booklore
        DATABASE_PASSWORD=${config.sops.placeholder.booklore-db-password}
      '';
    };
    templates.booklore-mariadb-env = {
      content = ''
        MARIADB_ROOT_PASSWORD=${config.sops.placeholder.booklore-db-root-password}
        MARIADB_DATABASE=booklore
        MARIADB_USER=booklore
        MARIADB_PASSWORD=${config.sops.placeholder.booklore-db-password}
      '';
    };
  };

  virtualisation.oci-containers.containers = {
    booklore = {
      image = "ghcr.io/booklore-app/booklore:latest";
      environmentFiles = [ config.sops.templates.booklore-env.path ];
      environment = {
        TZ = "America/Los_Angeles";
        DISK_TYPE = "NETWORK";
      };
      volumes = [
        "booklore-data:/app/data"
        "/mnt/media/books:/books:ro"
        "booklore-bookdrop:/bookdrop"
      ];
      dependsOn = [ "booklore-mariadb" ];
      extraOptions = [ "--network=host" ];
    };

    booklore-mariadb = {
      image = "mariadb:lts";
      environmentFiles = [ config.sops.templates.booklore-mariadb-env.path ];
      volumes = [
        "booklore-mariadb:/var/lib/mysql"
      ];
      extraOptions = [ "--network=host" ];
    };
  };
}
