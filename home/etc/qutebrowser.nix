{ inputs, lib, config, pkgs, systemConfig, ... }:
if systemConfig.useGUI then
  {
    programs.qutebrowser.enable = true;
  }
  else
  {
    programs.qutebrowser.enable = false;
  }
