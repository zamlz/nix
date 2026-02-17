#!/usr/bin/env python3

import os


import navi.system
from navi.logging import setup_main_logging
from navi.shell.fzf import Fzf
from navi.window_manager import set_window_title


RG_COMMAND=' '.join([
   "rg",
   "--line-number",
   "--column",
   "--no-heading",
   "--color=always",
   "--smart-case"
])


@setup_main_logging
def main() -> None:
    fs_ptr = navi.system.get_filesystem_pointer(False)
    os.chdir(fs_ptr)
    set_window_title(f"FZF: Interactive RipGrep ({fs_ptr})")
    fzf = Fzf(
        prompt="Ripgrep: ",
        header=f"(Currently in {fs_ptr})",
        delimiter=':',
        binds=[
            f"start:reload:{RG_COMMAND} \"\"",
            f"change:reload:{RG_COMMAND} {{q}} || true",
        ],
        preview="bat {1} --highlight-line {2}",
        preview_window="down,60%,border-top,+{2}+3/3",
        preview_label="[File Preview]"
    )
    selections = fzf.prompt()
    if selections == [""]:
        return

    for selection in selections:
        relative_file_path, line, column, _ = selection.split(':', maxsplit=3)
        absolute_file_path = fs_ptr / relative_file_path
        navi.system.open_file(absolute_file_path, int(line), int(column))


if __name__ == "__main__":
    main()
