_: {
  programs.git = {
    enable = true;
    settings = {
      alias = {
        root = "rev-parse --show-toplevel";
      };
      init = {
        defaultBranch = "main";
      };
      pull = {
        ff = "only";
      };
      user = {
        name = "Amlesh Sivanantham (zamlz)";
        email = "zamlz@pm.me";
      };
    };
    signing = {
      signByDefault = true;
      key = "0x882C395C3B28902C";
    };
  };

  # Let's update our shell to support some git aliases
  programs.zsh.shellAliases = {
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
    gP = "git pull";
    gf = "git fetch";
    gm = "git merge";
    gb = "git branch -av";
    gr = "git rev-parse --show-toplevel";
    grr = "git rev-parse --show-toplevel | xargs";
  };
}
