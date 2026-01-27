_: {
  xdg.configFile."scripts/navi" = {
    source = ./navi;
    recursive = true;
  };
  xdg.configFile = {
    "scripts/calculator.py".source = ./calculator.py;
    "scripts/file_preview.sh".source = ./file_preview.sh;
    "scripts/file_system_explorer.py".source = ./file_system_explorer.py;
    "scripts/file_system_open.py".source = ./file_system_open.py;
    "scripts/fzf-program-launcher.sh".source = ./fzf-program-launcher.sh;
    "scripts/git_manager.py".source = ./git_manager.py;
    "scripts/maim-screenshot.sh".source = ./maim-screenshot.sh;
    "scripts/man_open.py".source = ./man_open.py;
    "scripts/man_preview.sh".source = ./man_preview.sh;
    "scripts/nohup.sh".source = ./nohup.sh;
    "scripts/password-store.py".source = ./password_store.py;
    "scripts/ripgrep.py".source = ./ripgrep.py;
    "scripts/spawn_identical_shell.py".source = ./spawn_identical_shell.py;
    "scripts/system_manager.py".source = ./system_manager.py;
    "scripts/window_switcher.py".source = ./window_switcher.py;
    "scripts/workspace_manager.py".source = ./workspace_manager.py;
  };
}
