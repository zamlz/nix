{ inputs, lib, config, pkgs, ... }: let
  colorScheme = lib.attrsets.mapAttrs
    (name: value: builtins.replaceStrings ["#"]  ["rgb:"] value)
    (import ../common/colorscheme.nix).defaultColorScheme;
in {
  programs.kakoune = {
    config = {
      colorScheme = "navi";  # defined below
      numberLines = {
        enable = true;
        highlightCursor = true;
        relative = false;
        separator = "\" \"";
      };
      showMatching = true;
      ui = {
        assistant = "cat";
        changeColors = true;
        enableMouse = true;
        setTitle = true;
        statusLine = "bottom";
      };
    };
    defaultEditor = true;
    enable = true;
  };

  xdg.configFile."kak/colors/navi.kak".text = with colorScheme; ''
    # For Code
    face global value ${red}
    face global type ${yellow}
    face global variable ${green}
    face global module ${green}
    face global function ${cyan}
    face global string ${magenta}
    face global keyword ${blue}
    face global operator ${yellow}
    face global attribute ${green}
    face global comment ${blackAlt}
    face global documentation comment
    face global meta ${magenta}
    face global builtin default+b
    
    # For markup
    face global title ${blue}
    face global header ${cyan}
    face global mono ${green}
    face global block ${magenta}
    face global link ${cyan}
    face global bullet ${cyan}
    face global list ${yellow}
    
    # builtin faces
    face global Default default,default
    face global PrimarySelection white,${black}+fg
    face global SecondarySelection black,blue+fg
    face global PrimaryCursor black,white+fg
    face global SecondaryCursor black,white+fg
    face global PrimaryCursorEol black,cyan+fg
    face global SecondaryCursorEol black,cyan+fg
    face global LineNumbers ${blackAlt},${background}
    face global LineNumberCursor ${yellow},${background}+b
    face global MenuForeground ${black},${white}
    face global MenuBackground ${white},${black}
    face global MenuInfo cyan
    face global Information ${white},${background}
    face global Error ${background},red+b
    face global DiagnosticError red
    face global DiagnosticWarning yellow
    face global StatusLine cyan,default
    face global StatusLineMode yellow,default
    face global StatusLineInfo blue,default
    face global StatusLineValue green,default
    face global StatusCursor black,cyan
    face global Prompt yellow,default
    face global MatchingChar default,default+b
    face global Whitespace default,default+fd
    face global BufferPadding blue,default
  '';
}

