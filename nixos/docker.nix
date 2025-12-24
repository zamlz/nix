{
  ...
}:
{
  users.extraGroups.docker.members = [ "amlesh" ];

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };
  virtualisation.oci-containers.backend = "docker";
}
