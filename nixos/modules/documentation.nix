_: {
  # This enables documentation at a system level, but we still need to
  # apply the same settings in home-manager
  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    man = {
      enable = true;
      generateCaches = true;
      man-db.enable = true;
    };
    nixos.enable = true;
  };
}
