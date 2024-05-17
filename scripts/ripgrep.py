#!/usr/bin/env python3

import os
import site
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import navi.system
from navi.tools.fzf import Fzf
from navi.xorg import xwindow


RG_COMMAND="rg --line-number --no-heading --color=always --smart-case"


def main() -> None:
    fs_ptr = navi.system.get_filesystem_pointer(False)
    os.chdir(fs_ptr)
    xwindow.set_window_title(f"FZF: Interactive RipGrep in {fs_ptr}")
    fzf = Fzf(
        prompt="Ripgrep: ",
        delimiter=':',
        binds=[
            f"start:reload:{RG_COMMAND} \"\"",
            f"change:reload:{RG_COMMAND} {{q}} || true",
            "enter:become(echo {1})"
        ],
        preview=(
            "bat --color=always --style=numbers --theme=ansi "
            "{1} --highlight-line {2}"
        ),
        preview_window="down,60%,border-top,+{2}+3/3,~3"
    )
    file_name = fzf.prompt()[0]
    print(file_name)


if __name__ == "__main__":
    main()
