let
  #    ___              _               ___ _         _
  #  / __|_ _ _  ___ _| |__  _____ __ | _ ) |__ _ __| |__
  # | (_ | '_| || \ V / '_ \/ _ \ \ / | _ \ / _` / _| / /
  #  \___|_|  \_,_|\_/|_.__/\___/_\_\ |___/_\__,_\__|_\_\
  gruvboxBlack = {
    foreground = "#ebdbb2";
    background = "#000000";
    black = "#181818";
    red = "#cc241d";
    green = "#98971a";
    yellow = "#d79921";
    blue = "#458588";
    magenta = "#b16286";
    cyan = "#689d6a";
    white = "#a89984";
    blackAlt = "#928374";
    redAlt = "#fb4934";
    greenAlt = "#b8bb26";
    yellowAlt = "#fabd2f";
    blueAlt = "#83a598";
    magentaAlt = "#d3869b";
    cyanAlt = "#8ec07c";
    whiteAlt = "#ebdbb2";
  };
  #  __  __         _          __   ___                 _ _
  # |  \/  |___  __| |_  _ ___ \ \ / (_)_ _____ _ _  __| (_)
  # | |\/| / _ \/ _` | || (_-<  \ V /| \ V / -_) ' \/ _` | |
  # |_|  |_\___/\__,_|\_,_/__/   \_/ |_|\_/\___|_||_\__,_|_|
  modusVivendi = {
    background = "#000000";
    foreground = "#ffffff";
    black = "#000000";
    red = "#ff5f59";
    green = "#44bc44";
    yellow = "#d0bc00";
    blue = "#2fafff";
    magenta = "#feacd0";
    cyan = "#00d3d0";
    white = "#ffffff";
    blackAlt = "#1e1e1e";
    redAlt = "#ff5f5f";
    greenAlt = "#44df44";
    yellowAlt = "#efef00";
    blueAlt = "#338fff";
    magentaAlt = "#ff66ff";
    cyanAlt = "#00eff0";
    whiteAlt = "#989898";
  };
  #  _____    _            _  _ _      _   _     ___ _
  # |_   _|__| |___  _ ___| \| (_)__ _| |_| |_  / __| |_ ___ _ _ _ __
  #   | |/ _ \ / / || / _ \ .` | / _` | ' \  _| \__ \  _/ _ \ '_| '  \
  #   |_|\___/_\_\\_, \___/_|\_|_\__, |_||_\__| |___/\__\___/_| |_|_|_|
  #               |__/           |___/
  tokyoNightStorm = {
    background = "#24283b";
    foreground = "#c0caf5";
    black = "#1d202f";
    red = "#f7768e";
    green = "#9ece6a";
    yellow = "#e0af68";
    blue = "#7aa2f7";
    magenta = "#bb9af7";
    cyan = "#7dcfff";
    white = "#a9b1d6";
    blackAlt = "#414868";
    redAlt = "#ff899d";
    greenAlt = "#9fe044";
    yellowAlt = "#faba4a";
    blueAlt = "#8db0ff";
    magentaAlt = "#c7a9ff";
    cyanAlt = "#a4daff";
    whiteAlt = "#c0caf5";
  };
in
{
  defaultColorScheme = gruvboxBlack;
  allColorSchemes = {
    "gruvboxBlack" = gruvboxBlack;
    "modusVivendi" = modusVivendi;
    "tokyoNightStorm" = tokyoNightStorm;
  };
}
