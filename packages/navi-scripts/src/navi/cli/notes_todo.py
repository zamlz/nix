#!/usr/bin/env python3

import subprocess
import os
from pathlib import Path

import navi.system
from navi.logging import setup_main_logging
from navi.shell.fzf import Fzf
from navi.xorg.window import set_window_title


def collect_todos() -> list[str]:
    result = subprocess.run('notes-tasks', capture_output=True)
    result.check_returncode()
    return str(result.stdout, encoding="utf-8").strip().split("\n")


@setup_main_logging
def main() -> None:
    notes_directory = os.getenv('NOTES_DIRECTORY')
    if type(notes_directory) is not str:
        raise ValueError(f"Invalid value for notes directory: {notes_directory}")
    os.chdir(notes_directory)
    set_window_title(f"FZF: TODO ({notes_directory})")
    fzf = Fzf(
        prompt="TODO: ",
        header=f"(Currently in {notes_directory})",
        delimiter=':',
        preview="bat {1} --highlight-line {2}",
        preview_window="down,40%,border-top,+{2}+3/3",
        preview_label="[File Preview]"
    )
    selections = fzf.prompt(collect_todos())
    if selections == [""]:
        return

    for selection in selections:
        relative_file_path, line, column, _ = selection.split(':', maxsplit=3)
        absolute_file_path = Path(notes_directory) / relative_file_path
        navi.system.open_file(absolute_file_path, int(line), int(column))


if __name__ == "__main__":
    main()
