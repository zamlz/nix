#!/usr/bin/env python3

import argparse
import site
import sys
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import ps
import xorg
from fzf import Fzf


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--file", action="store_true")
    parser.add_argument("-d", "--directory", action="store_true")
    parser.add_argument("-g", "--global-search", action="store_true")
    args = parser.parse_args()
    if args.file == args.directory:
        raise ValueError("Mode must be -f or -d")

    filesystem_pointer = xorg.get_filesystem_pointer(args.global_search)
    fzf = Fzf(
        prompt=f"Open {'File' if args.file else 'Directory'}:",
        header=f"(Currently in {filesystem_pointer})",
        multi=True,
        preview=(
            str(Path(__file__).parent / "fzf-file-preview.sh") \
            + f" {filesystem_pointer}{{}}"
        )
    )

    selections = fzf.prompt(xorg.get_dir_items(
        filesystem_pointer,
        xorg.SearchMode.FILE if args.file else xorg.SearchMode.DIRECTORY
    ))

    if selections == [""]:
        sys.exit(0)


if __name__ == "__main__":
    main()
