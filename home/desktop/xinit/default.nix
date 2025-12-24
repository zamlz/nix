{
  ...
}:
{
  xdg.configFile."xinit/rc.sh".source = ./rc.sh;
  xdg.configFile."xinit/autostart.sh" = {
    source = ./autostart.sh;
    executable = true;
  };
}
