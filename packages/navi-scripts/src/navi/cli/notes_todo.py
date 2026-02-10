#!/usr/bin/env python3

import subprocess
import os
from pathlib import Path

import navi.system
from navi.logging import setup_main_logging
from navi.shell.fzf import Fzf
from navi.xorg.window import set_window_title

# FIXME: Should this really be hardcoded?
NOTES_DIRECTORY = Path.home() / 'usr/notes'

RG_COMMAND=[
   "rg",
   "--line-number",
   "--column",
   "--no-heading",
   "--color=always",
   "--smart-case",
   "-t",
   "md",
   "--",
   "^\\s*- \\[ \\]"
]


def collect_todos() -> list[str]:
    result = subprocess.run(RG_COMMAND, capture_output=True)
    result.check_returncode()
    return str(result.stdout, encoding="utf-8").strip().split("\n")


@setup_main_logging
def main() -> None:
    os.chdir(NOTES_DIRECTORY)
    set_window_title(f"FZF: TODO ({NOTES_DIRECTORY})")
    fzf = Fzf(
        prompt="TODO: ",
        header=f"(Currently in {NOTES_DIRECTORY})",
        delimiter=':',
        preview="bat {1} --highlight-line {2}",
        preview_window="down,60%,border-top,+{2}+3/3",
        preview_label="[File Preview]"
    )
    selections = fzf.prompt(collect_todos())
    if selections == [""]:
        return

    for selection in selections:
        relative_file_path, line, column, _ = selection.split(':', maxsplit=3)
        absolute_file_path = NOTES_DIRECTORY / relative_file_path
        navi.system.open_file(absolute_file_path, int(line), int(column))


if __name__ == "__main__":
    main()
