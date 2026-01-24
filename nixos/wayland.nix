{
  pkgs,
  systemConfig,
  ...
}:
{
  programs.niri.enable = systemConfig.useGUI;
  services.playerctld.enable = true;
}
