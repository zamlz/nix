{
  inputs,
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}: let
  colorScheme = (import ../config/colorschemes.nix).defaultColorScheme;
in {
  xsession.windowManager.herbstluftwm = {
    enable = true;
    extraConfig = ''
      herbstclient attr theme.border_width 9
      herbstclient attr theme.inner_width 3
      herbstclient attr theme.outer_width 4
      herbstclient attr theme.inner_color "${colorScheme.background}"
      herbstclient attr theme.outer_color "${colorScheme.background}"
      herbstclient attr theme.background_color "#141414"
      herbstclient attr theme.title_height 26
      herbstclient attr theme.title_depth 6
      herbstclient attr theme.title_font Iosevka:size=12.0

      herbstclient attr theme.normal.color "${colorScheme.black}"
      herbstclient attr theme.normal.title_color "${colorScheme.white}"
      herbstclient attr theme.normal.tab_title_color "${colorScheme.white}"


      herbstclient attr theme.active.color "#383838"
      herbstclient attr theme.active.outer_color "${colorScheme.background}"
      herbstclient attr theme.active.inner_color "${colorScheme.background}"
      herbstclient attr theme.active.title_color "${colorScheme.foreground}"
      herbstclient attr theme.active.tab_title_color "${colorScheme.white}"


      herbstclient attr theme.urgent.color orange

      herbstclient attr theme.floating.border_width 9
      herbstclient attr theme.floating.inner_width 3
      herbstclient attr theme.floating.outer_width 4
      herbstclient attr theme.floating.outer_color "${colorScheme.background}"
      herbstclient attr theme.floating.title_height 0
      herbstclient attr theme.floating.active.color "${colorScheme.foreground}"


      herbstclient emit_hook reload
      herbstclient detect_monitors

      # configures wallpaper, bars, other key mappers, various general xorg settings, etc.
      ~/.config/xinit/autostart.sh
    '';
    # mod4 is SUPER
    # You can use xev to identify X11 keys very easily!
    keybinds = let
      super = "Mod4";
      resizestep = "0.01";
    in {
      # This is a backup quit option in case sxhkd fails
      "${super}-Ctrl-Alt-Shift-Escape" = "quit";

      # Reload WM and Close Window
      "${super}-Ctrl-Alt-r" = "chain , spawn $HOME/etc/xorg/refresh.sh , reload";
      "${super}-Ctrl-r" = "reload";
      "${super}-q" = "close";

      # Window Focus
      "${super}-h" = "focus left";
      "${super}-j" = "focus down";
      "${super}-k" = "focus up";
      "${super}-l" = "focus right";

      # defining keybindings for cycling the focused client
      #"${super}-BackSpace" = "cycle_monitor";  # FIXME: this is used already
      "${super}-Tab" = "cycle +1";
      "${super}-Shift-Tab" = "cycle -1";
      "${super}-Control-Tab" = "cycle_frame +1";
      "${super}-Control-Shift-Tab" = "cycle_frame -1";
      "${super}-Control-Alt-Tab" = "cycle_all +1";
      "${super}-Control-Alt-Shift-Tab" = "cycle_all -1";
      "${super}-i" = "jumpto urgent";

      # Window Movement
      "${super}-Shift-h" = "shift left";
      "${super}-Shift-j" = "shift down";
      "${super}-Shift-k" = "shift up";
      "${super}-Shift-l" = "shift right";

      # Splitting Frames
      "${super}-u" = "split bottom 0.5";
      "${super}-o" = "split right 0.5";
      "${super}-Control-space" = "split explode";
      "${super}-r" = "remove";

      # Resizing Frames
      "${super}-Control-h" = "resize left +${resizestep}";
      "${super}-Control-Alt-h" = "resize left -${resizestep}";
      "${super}-Control-j" = "resize down +${resizestep}";
      "${super}-Control-Alt-j" = "resize down -${resizestep}";
      "${super}-Control-k" = "resize up +${resizestep}";
      "${super}-Control-Alt-k" = "resize up -${resizestep}";
      "${super}-Control-l" = "resize right +${resizestep}";
      "${super}-Control-Alt-l" = "resize right -${resizestep}";

      # Workspace Movement
      "${super}-grave" = "use_previous";
      "${super}-bracketright" = "use_index +1 --skip-visible";
      "${super}-bracketleft" = "use_index -1 --skip-visible";

      # Layout Control
      "${super}-s" = "floating toggle";
      "${super}-t" = "pseudotile toggle";
      "${super}-f" = "fullscreen toggle";

      # The following cycles through the available layouts within a frame, but skips
      # layouts, if the layout change wouldn't affect the actual window positions.
      # (I.e. if there are two windows within a frame, the grid layout is skipped.)
      "${super}-space" = ''
        or , and . compare tags.focus.curframe_wcount = 2 \
                 . cycle_layout +1 vertical horizontal max vertical grid \
           , cycle_layout +1
      '';

      # Tag Definitions (workspaces)
      "${super}-1" = "use_index 0";
      "${super}-2" = "use_index 1";
      "${super}-3" = "use_index 2";
      "${super}-4" = "use_index 3";
      "${super}-5" = "use_index 4";
      "${super}-6" = "use_index 5";
      "${super}-7" = "use_index 6";
      "${super}-8" = "use_index 7";
      "${super}-9" = "use_index 8";
      "${super}-0" = "use_index 9";
      "${super}-Shift-1" = "move_index 0";
      "${super}-Shift-2" = "move_index 1";
      "${super}-Shift-3" = "move_index 2";
      "${super}-Shift-4" = "move_index 3";
      "${super}-Shift-5" = "move_index 4";
      "${super}-Shift-6" = "move_index 5";
      "${super}-Shift-7" = "move_index 6";
      "${super}-Shift-8" = "move_index 7";
      "${super}-Shift-9" = "move_index 8";
      "${super}-Shift-0" = "move_index 9";
    };
    mousebinds = let
      super = "Mod4";
    in {
      "${super}-Button1" = "move";
      "${super}-Button2" = "zoom";
      "${super}-Button3" = "resize";
    };
    # We have a rule here that makes `termprompt` type windows automatically
    # float. This is used for the custom fzf-alacritty scripts spawned by
    # sxhkd.
    rules = [
      "focus=on"
      "class~'termprompt' floating=on floatplacement=center"
      "title~'feh:pass:.*' floating=on floatplacement=center"
      "windowtype~'_NET_WM_WINDOW_TYPE_(DIALOG|UTILITY|SPLASH)' pseudotile=on"
      "windowtype='_NET_WM_WINDOW_TYPE_DIALOG' focus=on"
      "windowtype~'_NET_WM_WINDOW_TYPE_(NOTIFICATION|DOCK|DESKTOP)' manage=off"
    ];
    settings = {
      "frame_transparent_width" = 0;
      "frame_border_width" = 2;
      "frame_border_active_color" = "${colorScheme.foreground}";
      "frame_border_normal_color" = "#000000"; # add extra "00" for transparency
      "frame_bg_transparent" = 1;
      "frame_bg_normal_color" = "${colorScheme.background}";
      "frame_bg_active_color" = "${colorScheme.black}";
      "always_show_frame" = 0;
      "frame_gap" = 0; # 20 is what you want if you want gaps
      "frame_padding" = 0;
      "window_gap" = 0;
      "smart_window_surroundings" = 0;
      "smart_frame_surroundings" = 0;
      "mouse_recenter_gap" = 0;
      "tree_style" = "╾│ ├└╼─┐";
    };
    tags = ["λ"];
  };
}
