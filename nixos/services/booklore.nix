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
        DATABASE_URL=jdbc:mariadb://booklore-mariadb:3306/booklore
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

  # Create a dedicated Docker network so booklore and mariadb can
  # communicate by container name without using host networking.
  systemd.services = {
    docker-network-booklore = {
      description = "Create Docker network for Booklore";
      after = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ config.virtualisation.docker.package ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = "docker network inspect booklore >/dev/null 2>&1 || docker network create booklore";
      postStop = "docker network rm booklore || true";
    };
    docker-booklore.after = [ "docker-network-booklore.service" ];
    docker-booklore-mariadb.after = [ "docker-network-booklore.service" ];
  };

  virtualisation.oci-containers.containers = {
    booklore = {
      image = "ghcr.io/booklore-app/booklore:latest";
      environmentFiles = [ config.sops.templates.booklore-env.path ];
      environment = {
        TZ = "America/Los_Angeles";
        DISK_TYPE = "NETWORK";
        USER_ID = "0";
        GROUP_ID = "0";
      };
      volumes = [
        "booklore-data:/app/data"
        "/mnt/media/books:/books:ro"
        "booklore-bookdrop:/bookdrop"
      ];
      ports = [ "${toString constants.services.booklore.port}:6060" ];
      dependsOn = [ "booklore-mariadb" ];
      extraOptions = [ "--network=booklore" ];
    };

    booklore-mariadb = {
      image = "mariadb:lts";
      environmentFiles = [ config.sops.templates.booklore-mariadb-env.path ];
      volumes = [
        "booklore-mariadb:/var/lib/mysql"
      ];
      extraOptions = [ "--network=booklore" ];
    };
  };
}
