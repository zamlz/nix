#!/usr/bin/env python3

import argparse
import logging
import site
import subprocess
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


SPAWN_TERMINAL_ACTION = "__SPAWN_TERMINAL_ACTION__"
TOGGLE_HIDDEN_ACTION = "__TOGGLE_HIDDEN_ACTION__"


def fzf_file_explorer_prompt(fs_ptr: Path, show_hidden: bool) -> str:
    ls_hidden_arg = ["-A"] if show_hidden else []
    result = subprocess.run(
        ["ls", "-lh", *ls_hidden_arg, "--color=always"],
        capture_output=True,
        cwd=fs_ptr
    )
    result.check_returncode()
    ls_output = str(result.stdout, encoding="utf-8").strip().split('\n')
    fzf = Fzf(
        prompt=f"FsExplorer: ",
        header=f"(Currently in {fs_ptr})",
        header_lines=1,
        preview=(
            str(Path(__file__).parent / "file_preview.sh") \
            + f" {fs_ptr}/{{9}}"
        ),
        nth=9,
        binds=[
            f"ctrl-h:become(echo {TOGGLE_HIDDEN_ACTION})",
            f"alt-enter:become(echo {SPAWN_TERMINAL_ACTION})",
            "alt-h:become(echo ..)",
            "alt-j:down",
            "alt-k:up",
            "alt-l:become(echo {9})",
            "enter:become(echo {9})",
        ]
    )
    return fzf.prompt(ls_output)[0]


def main() -> None:
    fs_ptr = navi.system.get_filesystem_pointer(False, find_git_root=False)
    show_hidden = False

    while fs_ptr.is_dir():
        set_window_title(f"FZF: File System Explorer (in {fs_ptr})")
        selection = fzf_file_explorer_prompt(fs_ptr, show_hidden)
        fs_ptr_with_selection = fs_ptr / selection

        if selection == '':
            return

        elif selection == TOGGLE_HIDDEN_ACTION:
            show_hidden = not show_hidden

        elif selection == SPAWN_TERMINAL_ACTION:
            navi.system.open_dir(fs_ptr)
            return

        elif fs_ptr_with_selection.is_file():
            navi.system.open_file(fs_ptr_with_selection)
            return

        elif fs_ptr_with_selection.is_dir():
            fs_ptr = fs_ptr_with_selection.resolve()

        else:
            raise ValueError(f"Invalid selection: {selection}")

    raise ValueError(f"Unexpected exit of loop on {fs_ptr}")


if __name__ == "__main__":
    setup_logger()
    main()
