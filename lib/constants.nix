rec {
  # The stateVersion is used in both the system config and the
  # home-manager configuration. Please read the notes for two use-cases
  # before editing this value.
  #
  # NixOS System:
  #   This value determines the NixOS release from which the default
  #   settings for stateful data, like file locations and database
  #   versions on your system were taken. It's perfectly fine and
  #   recommended to leave this value at the release version of the
  #   first install of this system. Before changing this value read the
  #   documentation for this option (e.g. man configuration.nix or on
  #   https://nixos.org/nixos/options.html).
  #
  # Home Manager:
  #   State versions define the NixOS/home-manager release compatibility
  #   DO NOT CHANGE these values without reading the documentation
  #   See: https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  stateVersion = "23.05";

  lanSubnet = "10.69.8.0/24";
  parentSubnet = "10.69.0.0/16";

  hostIpAddressMap = {
    solaris = "10.69.8.0";
    xynthar = "10.69.8.2";
    yggdrasil = "10.69.8.3";
    alexandria = "10.69.8.4";
  };

  nasHost = "alexandria";

  domainSuffix = "lab.zamlz.org";

  # Service registry
  services = {
    blocky = {
      host = "yggdrasil";
      port = 4000;
      meta = {
        name = "Blocky";
        group = "Utilities";
        description = "DNS server and ad blocker";
        icon = "blocky";
      };
    };
    grafana = {
      host = "yggdrasil";
      port = 3000;
      meta = {
        name = "Grafana";
        group = "Utilities";
        description = "Monitoring dashboards";
        icon = "grafana";
      };
    };
    homepage = {
      host = "yggdrasil";
      port = 3030;
    };
    immich = {
      host = "solaris";
      port = 2283;
      meta = {
        name = "Immich";
        group = "Media & Apps";
        description = "Photo and video management";
        icon = "immich";
      };
    };
    jellyfin = {
      host = "yggdrasil";
      port = 8096;
      meta = {
        name = "Jellyfin";
        group = "Media & Apps";
        description = "Media server";
        icon = "jellyfin";
      };
    };
    kavita = {
      host = "yggdrasil";
      port = 5000;
      meta = {
        name = "Kavita";
        group = "Media & Apps";
        description = "Book and manga reader";
        icon = "kavita";
      };
    };
    openwebui = {
      host = "solaris";
      port = 8080;
      meta = {
        name = "Open WebUI";
        group = "Media & Apps";
        description = "Ollama LLM interface";
        icon = "open-webui";
      };
    };
    prometheus = {
      host = "yggdrasil";
      port = 9090;
    };
  };

  # Services with meta — proxied by Caddy, DNS entries in Blocky, shown on dashboard
  publicServices = builtins.listToAttrs (
    builtins.filter (entry: entry.value ? meta) (
      map (name: {
        inherit name;
        value = services.${name};
      }) (builtins.attrNames services)
    )
  );

  # Multi-host / infrastructure ports (not tied to a single service)
  ports = {
    glances = 61208;
    nfs = 2049;
    prometheusNodeExporter = 9100;
  };
}
