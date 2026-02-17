{
  config,
  ...
}:
{
  home = {
    sessionPath = [ "${config.home.homeDirectory}/.local/notes-bin" ];
    sessionVariables = {
      NOTES_DIRECTORY = "${config.home.homeDirectory}/usr/notes";
    };
    file = {
      ".local/notes-bin/notes-tasks" = {
        executable = true;
        source = ./tasks.sh;
      };
      ".local/notes-bin/notes-log-journal" = {
        executable = true;
        source = ./log_journal.sh;
      };
    };
  };
}
