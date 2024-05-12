{ inputs, lib, config, pkgs, ... }: {
  # Because qtile is not yet managed by home-manager, we need to make sure we
  # add it to the package list for the user
  xdg.configFile."qtile".source = ./src;
  xdg.configFile."qtile".recursive = true;
}
