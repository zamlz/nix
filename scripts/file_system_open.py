#!/usr/bin/env python3

import argparse
import site
from pathlib import Path

from loguru import logger

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import navi.system
from navi.logging import setup_main_logging
from navi.shell.fzf import Fzf
from navi.xorg.window import set_window_title


TOGGLE_HIDDEN_ACTION = "__TOGGLE_HIDDEN_ACTION__"


@setup_main_logging
def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--file", action="store_true")
    parser.add_argument("-d", "--directory", action="store_true")
    parser.add_argument("-g", "--global-search", action="store_true")
    args = parser.parse_args()
    if args.file == args.directory:
        raise ValueError("Mode must be -f or -d")
    elif args.file:
        fs_object = "File"
        search_mode = navi.system.SearchMode.FILE
    else:
        fs_object = "Directory"
        search_mode = navi.system.SearchMode.DIRECTORY

    fs_ptr = navi.system.get_filesystem_pointer(args.global_search)
    set_window_title(f"FZF: Open {fs_object} (from {fs_ptr})")

    fzf = Fzf(
        prompt=f"Open {fs_object}: ",
        header=f"(Currently in {fs_ptr})",
        multi=True,
        preview=(
            str(Path(__file__).parent / "file_preview.sh") \
            + f" {fs_ptr}/{{}}"
        ),
        binds=[f"ctrl-h:become(echo {TOGGLE_HIDDEN_ACTION})"]
    )

    show_hidden = False
    while True:
        dir_items = navi.system.get_dir_items(
            root_dir=fs_ptr,
            mode=search_mode,
            show_hidden=show_hidden
        )
        selections = fzf.prompt(dir_items)
        if selections == [TOGGLE_HIDDEN_ACTION]:
            show_hidden = not show_hidden
            continue
        elif selections == [""]:
            return
        else:
            selected_items = [fs_ptr / p for p in selections]
            navi.system.open_items(selected_items)
            return


if __name__ == "__main__":
    main()
