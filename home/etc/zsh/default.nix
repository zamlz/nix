{
  inputs,
  lib,
  config,
  pkgs,
  systemConfig,
  ...
}: let
  readFileList = files:
    builtins.concatStringsSep "\n"
    (map (f: builtins.readFile f) files);
in {
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autocd = true;
    defaultKeymap = "viins";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
      patterns = {
        "rm -rf *" = "fg=white,bold,bg=red";
      };
    };
    enableVteIntegration = true;
    historySubstringSearch = {
      enable = true;
      #searchDownKey = ["j"];
      #searchUpKey = ["k"];
    };
    history = {
      extended = true;
      expireDuplicatesFirst = true;
      ignoreSpace = true;
      share = true;
      ignorePatterns = [
        "pkill *"
        "rm *"
        "rmdir *"
      ];
      save = 100000;
      size = 100000;
    };
    # NOTE: Application specific aliases (ex: git) can be found in their
    # respective nixos configuration file
    shellAliases = {
      # the vi command is a hard habit to break
      vi = "$EDITOR";
      # aliasing these guys to make them safer
      rm = "rm -I --preserve-root";
      mv = "mv -i";
      cp = "cp -i";
      # misc aliases that are useful/fun
      please = "sudo";
      weather = "curl wttr.in";
    };
    loginExtra =
      if systemConfig.useGUI
      then builtins.readFile ./login.zsh
      else "";
    envExtra = builtins.readFile ./environment.zsh;
    initContent = readFileList [
      ./init/prompt.zsh
      ./init/hooks.zsh
      ./init/jobs.zsh
      ./init/substring-search.zsh
      ./init/python-venv.zsh
      ./init/encryption.zsh
    ];
  };
}
