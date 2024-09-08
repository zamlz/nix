{ inputs, lib, config, pkgs, ... }: let
  readFileList = files:
    builtins.concatStringsSep "\n"
      (map (f: builtins.readFile f) files);
in {
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    autocd = true;
    defaultKeymap = "viins";
    enableCompletion = true;
    autosuggestion.enable= true;
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
      # Shortcuts for ls
      ls = "LC_COLLATE=C ls -F --color=always";
      ll = "ls -oh";
      la = "ls -lah";
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
    loginExtra = builtins.readFile ./login.zsh;
    envExtra = builtins.readFile ./environment.zsh;
    initExtra = readFileList [
      ./init/prompt.zsh
      ./init/hooks.zsh
      ./init/jobs.zsh
      ./init/substring-search.zsh
      ./init/python-venv.zsh
      ./init/encryption.zsh
      ./init/nixos.zsh
    ];
  };
}
