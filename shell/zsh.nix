{ inputs, lib, config, pkgs, ... }: {
  xdg.configFile."zsh/prompt.zsh".source = ./resources/zsh-prompt.zsh;
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    autocd = true;
    defaultKeymap = "viins";
    enableCompletion = true;
    autosuggestion.enable= true;
    syntaxHighlighting.enable = true;
    enableVteIntegration = true;
    history = {
      extended = true;
      ignoreSpace = true;
      ignorePatterns = [
        "rm *"
        "pkill *"
      ];
      save = 100000;
    };
    shellAliases = {
      # Shortcuts for ls
      ls = "LC_COLLATE=C ls -F --color=always";
      ll = "ls -oh";
      la = "ls -lah";
      # Shell aliases to make using git easier.
      gg = "lazygit";
      gs = "echo \"\\e[0;36morigin\\e[0m = \\e[0;34m$(git remote get-url origin --push)\\e[0m\"; git status";
      ga = "git add";
      gc = "git commit";
      gd = "git diff";
      gds = "git diff --staged";
      gl = "git log --graph";
      gls = "git log --graph --stat";
      gll = "git log --graph --stat -p";
      gllo = "git log --graph --pretty=oneline --abbrev-commit";
      glla = "git log --graph --pretty=oneline --abbrev-commit --all";
      gp = "git push";
      gf = "git fetch";
      gm = "git merge";
      gb = "git branch -av";
      gr = "git rev-parse --show-toplevel";
      grr = "git rev-parse --show-toplevel | xargs";
      # make all vi/vim point to neovim
      vi = "$EDITOR";
      vim = "nvim";
      # aliasing these guys to make them safer
      rm = "rm -I --preserve-root";
      mv = "mv -i";
      cp = "cp -i";
      # misc aliases that are useful/fun
      please = "sudo";
      weather = "curl wttr.in";
    };
    loginExtra = ''
      if [ -z "$DISPLAY" ] && [ "$(fgconsole 2>/dev/null)" -eq 1 ]; then
          exec startx $HOME/.config/xinit/rc.sh "herbstluftwm"
      elif [ -z "$DISPLAY" ] && [ "$(fgconsole 2>/dev/null)" -eq 2 ]; then
          exec startx $HOME/.config/xinit/rc.sh "qtile start --backend x11"
      elif [ -z "$DISPLAY" ] && [ "$(fgconsole 2>/dev/null)" -eq 3 ]; then
          exec qtile start --backend wayland
      fi
    '';
    envExtra = ''
      export LESS="-R --no-init --quit-if-one-screen"
      # no longer creates __pycache__ folders in the same folder as *.py files
      export PYTHONPYCACHEPREFIX="$HOME/.cache/__pycache__"

      # prepare the window id directory
      WINDIR=/tmp/.wid
      mkdir -p $WINDIR

      # Load window info for given Target Window ID (used with pwdcfw.sh)
      function load_window_info() {
          if [ -n "$DISPLAY" ] && [ -n "$TARGET_WINDOWID" ]; then
              source "$WINDIR/$TARGET_WINDOWID"
              cd $WINDOW_PWD
              unset TARGET_WINDOWID
          fi
      }

      # Save window info for given Window ID (used with pwdcfw.sh)
      function save_window_info() {
          if [ -n "$DISPLAY" ] && [ -n "$WINDOWID" ]; then
              WINDOWID_FILE="$WINDIR/$WINDOWID"
              echo "WINDOW_PWD='$(pwd)'" | tee $WINDOWID_FILE
          fi
      }

      # Finally, just save the window info in case other processes are started without
      # ever needing a zsh prompt (alacritty spawners)
      save_window_info > /dev/null 2>&1
    '';
    initExtra = ''
      source $HOME/.config/zsh/prompt.zsh

      # register hooks before the user is given the oppurtunity to enter a command
      precmd() {
          # load terminal window info if it exists
          load_window_info > /dev/null 2>&1
          export PROMPT=$(prompt_generate $?)
          # save terminal window info (creates id file)
          save_window_info > /dev/null 2>&1
          # update the terminal title
          # FIXME: maybe incorporate previously run command if exists?
          print -Pn "\e]0;zsh %(1j,%j job%(2j|s|); ,)%~\a"
      }

      # register hooks to run after accepting a command but before executing it
      preexec() {
          # writes the command and it's arguments to the title
          # FIXME: does not work with fg well
          printf "\033]0;%s\a" "$1"
      }

      # FIXME: Eventually make this a widget like the fzf-zsh-history plugin (ctrl-r)
      fzf-foreground-job() {
          [ -z "$(jobs)" ] && fg && return;
          fg %$(jobs | fzf --bind 'enter:become(echo %{1})' | tr -d '[]')
      }
      bindkey -s "^F" 'fzf-foreground-job^M'

      autobg-ctrl-b () {
        if [[ $#BUFFER -eq 0 ]]; then
          echo ""
          bg
          zle redisplay
        else
          zle push-input
        fi
      }
      zle -N autobg-ctrl-b
      bindkey '^B' autobg-ctrl-b
    '';
  };
}
