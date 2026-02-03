{
  config,
  ...
}:
{
  # use: nix run nixpkgs#mangal mini -- --format cbz -d
  virtualisation.oci-containers.containers.kavita = {
    image = "jvmilazz0/kavita:latest";
    autoStart = true;
    environment = {
      TZ = config.time.timeZone;
    };
    ports = [ "5000:5000" ];
    pull = "always";
    volumes = [
      "/mnt/media/books/manga:/manga" # FIXME: Dynamically infer this from my filesystem config
      "/var/lib/kavita:/kavita/config"
    ];
  };
}
