{ inputs, lib, config, pkgs, ... }: {
  xdg.configFile."xinit/rc.sh".source = ./scripts/xinitrc.sh;
  xdg.configFile."xinit/autostart.sh".executable = true;
  xdg.configFile."xinit/autostart.sh".text = ''
    #!/bin/sh
    # utilities
    $HOME/.fehbg
    (pkill sxhkd; sleep 0.1; ${pkgs.sxhkd}/bin/sxhkd) &
    (pkill picom; sleep 0.1; ${pkgs.picom}/bin/picom) &
    (pkill -f "polybar top"; sleep 0.1; ${pkgs.polybar}/bin/polybar top) &
    (pkill -f "polybar bot"; sleep 0.1; ${pkgs.polybar}/bin/polybar bot) &

    # xorg settings
    xset r rate 400 50
    xset s off
    setxkbmap -option caps:escape
  '';
}
