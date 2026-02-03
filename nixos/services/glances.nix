_: {
  services.glances = {
    enable = true;
    extraArgs = [
      "--webserver"
    ];
    openFirewall = true;
  };
}
