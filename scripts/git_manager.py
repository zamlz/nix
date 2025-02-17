#!/usr/bin/env python3

import os
import site
import sys
from argparse import ArgumentParser
from pathlib import Path
from typing import List

from loguru import logger

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import navi.system
from navi.logging import setup_main_logging
from navi.shell.colors import AnsiColor
from navi.shell.fzf import Fzf
from navi.xorg.window import set_window_title


def launch_lazygit(directory: Path) -> None:
    os.chdir(directory)
    set_window_title(f"LazyGit: {directory}")
    navi.system.execute(["lazygit"])


def git_color_if_modified(directory: Path) -> str:
    if navi.system.git_status(directory) == '':
        return str(directory)
    return f"{AnsiColor.RED}{directory}{AnsiColor.RESET}"


def get_git_directories() -> List[Path]:
    set_window_title(f"LazyGit: Directory Lookup")
    fzf = Fzf(
        prompt="Git Directory: ",
        preview=(
            "git -c color.ui=always -C {} status && "
            "PAGER=cat git -c color.ui=always -C {} diff"
        ),
        ansi=True,
        multi=True
    )
    git_dir_list = navi.system.get_dir_items(
        root_dir=Path.home(),
        mode=navi.system.SearchMode.DIRECTORY,
        show_hidden=True,
        pattern=".git",
    )
    git_dir_list = [(Path.home() / g).parent for g in git_dir_list]
    git_dir_list = [git_color_if_modified(g) for g in git_dir_list]
    selection = fzf.prompt(git_dir_list)
    print(selection)
    if selection[0] == '':
        sys.exit(0)
    return [Path(g) for g in selection]


@setup_main_logging
def main() -> None:
    parser = ArgumentParser()
    parser.add_argument("--open-dir", action="store_true")
    args = parser.parse_args()

    if not args.open_dir:
        filesystem_pointer = navi.system.get_filesystem_pointer(False)
        if (filesystem_pointer / '.git').exists():
            launch_lazygit(filesystem_pointer)

    git_directories = get_git_directories()
    navi.system.open_items(git_directories)


if __name__ == "__main__":
    main()
