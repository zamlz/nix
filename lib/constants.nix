{
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
}
