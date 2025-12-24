{
  ...
}:
{
  # A simple, fast and user-friendly alternative to 'find'
  programs.fastfetch = {
    enable = true;
  };

  # Why not have a easy and nice way of typing fastfetch hmm?
  programs.zsh.shellAliases = {
    ff = "fastfetch";
  };
}
