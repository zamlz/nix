#!/usr/bin/env python3

import subprocess
import os
from pathlib import Path

import navi.system
from navi.logging import setup_main_logging
from navi.shell.fzf import Fzf
from navi.window_manager import set_window_title


# FIXME: We need this because NIRI session currently doesn't exist
# in niri-flake, meaning that home-manager cannot pass it's session
# variables to niri. I am using a system-wide niri-session, but it
# doesn't understand the existence of home manager so here we are.
def get_notes_directory() -> Path:
    result = subprocess.run(
        ["zsh", "-c", "printenv NOTES_DIRECTORY"],
        capture_output=True,
    )
    result.check_returncode()
    return Path(str(result.stdout, encoding="utf-8").strip())


def collect_todos() -> list[str]:
    result = subprocess.run('notes-tasks', capture_output=True)
    result.check_returncode()
    return str(result.stdout, encoding="utf-8").strip().split("\n")


@setup_main_logging
def main() -> None:
    notes_directory = get_notes_directory()
    if not notes_directory.exists():
        raise ValueError(f"{notes_directory} is not a valid path")
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
        absolute_file_path = notes_directory / relative_file_path
        navi.system.open_file(absolute_file_path, int(line), int(column))


if __name__ == "__main__":
    main()
