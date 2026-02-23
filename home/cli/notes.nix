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
        text = /* sh */ ''
          #!/usr/bin/env sh
          cd $NOTES_DIRECTORY

          rg \
            --color=always \
            --column \
            --line-number \
            --no-heading \
            --smart-case \
            --type=md \
            -- '^\s*- \[ \]' \
        '';
      };
      ".local/notes-bin/notes-log-journal" = {
        executable = true;
        text = /* sh */ ''
          #!/usr/bin/env sh

          JOURNAL_FILE="$NOTES_DIRECTORY/journal.md"

          ENTRY_MARKER="======="
          DATE_FORMAT="+%Y-%m-%d %I:%M:%S %p %Z"

          _make_temp_file() {
              mktemp tmp.XXXXXXXX.md --tmpdir=/tmp
          }

          add_new_log_entry() {
              entry_line=$(grep -n "$ENTRY_MARKER" $JOURNAL_FILE | cut -d: -f1)
              echo "Adding entry to $JOURNAL_FILE to lineno: $entry_line"

              entry_time=$(date "$DATE_FORMAT")
              echo "Entry time: $entry_time"

              temp_file_original=$(_make_temp_file)
              cp $JOURNAL_FILE $temp_file_original
              sed -i "''${entry_line}a\\\n## $entry_time" $temp_file_original

              edit_line=$(($entry_line + 2))

              temp_file_editable=$(_make_temp_file)
              cp $temp_file_original $temp_file_editable

              $EDITOR $temp_file_editable +$edit_line

              if diff $temp_file_editable $temp_file_original > /dev/null; then
                  echo "No change detected"
              else
                  echo "change detected, overwriting file"
                  cp $temp_file_editable $JOURNAL_FILE
             fi

              rm $temp_file_editable
              rm $temp_file_original
          }

          add_new_log_entry
        '';
      };
    };
  };
}
