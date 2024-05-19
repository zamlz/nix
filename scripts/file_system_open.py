#!/usr/bin/env python3

import argparse
import logging
import site
import sys
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import navi.system
from navi.logging import setup_logger
from navi.tools.fzf import Fzf
from navi.xorg import xwindow


logger = logging.getLogger(__name__)


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
    xwindow.set_window_title(f"FZF: Open {fs_object} (from {fs_ptr})")

    fzf = Fzf(
        prompt=f"Open {fs_object}:",
        header=f"(Currently in {fs_ptr})",
        multi=True,
        preview=(
            str(Path(__file__).parent / "file_preview.sh") \
            + f" {fs_ptr}/{{}}"
        )
    )

    selections = fzf.prompt(navi.system.get_dir_items(fs_ptr, search_mode))
    if selections == [""]:
        sys.exit(0)
    selected_items = [fs_ptr / p for p in selections]
    navi.system.open_items(selected_items)


if __name__ == "__main__":
    setup_logger()
    main()
