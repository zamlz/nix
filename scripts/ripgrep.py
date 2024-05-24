#!/usr/bin/env python3

import logging
import os
import site
import sys
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import navi.system
from navi.logging import setup_logger
from navi.tools.fzf import Fzf
from navi.xorg.window import set_window_title


logger = logging.getLogger(__name__)
RG_COMMAND=' '.join([
   "rg",
   "--line-number",
   "--column",
   "--no-heading",
   "--color=always",
   "--smart-case"
])


def main() -> None:
    fs_ptr = navi.system.get_filesystem_pointer(False)
    os.chdir(fs_ptr)
    set_window_title(f"FZF: Interactive RipGrep in {fs_ptr}")
    fzf = Fzf(
        prompt="Ripgrep: ",
        header=f"(Currently in {fs_ptr})",
        delimiter=':',
        binds=[
            f"start:reload:{RG_COMMAND} \"\"",
            f"change:reload:{RG_COMMAND} {{q}} || true",
        ],
        preview=(
            "bat --color=always --style=numbers --theme=ansi "
            "{1} --highlight-line {2}"
        ),
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
    setup_logger()
    main()
