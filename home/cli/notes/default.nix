{
  pkgs,
  config,
  ...
}:
{
  home.sessionPath = [ "${config.home.homeDirectory}/.local/notes-bin" ];
  home.sessionVariables = {
    NOTES_DIRECTORY = "${config.home.homeDirectory}/usr/notes";
  };
  home.file = {
    ".local/notes-bin/notes-tasks" = {
      executable = true;
      source = ./tasks.sh;
    };
    ".local/notes-bin/notes-log-journal" = {
      executable = true;
      source = ./log_journal.sh;
    };
  };
}
