_: {
  xdg.configFile."xinit/rc.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      # setting up the user dbus daemon is missing on nixos if we use startx
      if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
          eval $(dbus-launch --exit-with-session --sh-syntax)
      fi
      systemctl --user import-environment DISPLAY XAUTHORITY
      if command -v dbus-update-activation-environment >/dev/null 2>&1; then
          dbus-update-activation-environment DISPLAY XAUTHORITY
      fi
      # Figure out where to place these (maybe systemd user services)
      exec herbstluftwm
    '';
  };
  xdg.configFile."xinit/autostart.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      # utilities
      $HOME/.fehbg &
      (pkill sxhkd; sleep 0.1; sxhkd) &
      (pkill -f "polybar top"; sleep 0.1; polybar top) &
      (pkill -f "polybar bot"; sleep 0.1; polybar bot) &
      # xorg settings
      xset r rate 400 50
      xset s off
      setxkbmap -option caps:escape
    '';
  };
}
