#!/usr/bin/env python3

import os
import re
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


def remove_ansi_codes(text: str) -> str:
    return re.sub(r'\x1b\[.*?m', '', text)


def git_color_if_modified(directory_str: str) -> str:
    directory_str_clean = remove_ansi_codes(directory_str)
    directory = Path(directory_str_clean)
    git_status = navi.system.git_status(Path.home() / directory)
    if git_status == '':
        return directory_str
    return f"{AnsiColor.BOLD}{AnsiColor.RED}{directory_str_clean}{AnsiColor.RESET}"


def get_git_directories() -> List[Path]:
    set_window_title(f"LazyGit: Directory Lookup")
    fzf = Fzf(
        prompt="Git Directory: ",
        preview=(
            "git -c color.ui=always -C ~/{} status && "
            "PAGER=cat git -c color.ui=always -C ~/{} diff"
        ),
        ansi=True,
        multi=True
    )
    git_dir_list = navi.system.get_dir_items(
        root_dir=Path.home(),
        mode=navi.system.SearchMode.DIRECTORY,
        show_unrestricted=True,
        pattern=r"\.git$",
    )
    git_dir_list = [g.replace('.git\x1b[0m\x1b[1;34m/', '') for g in git_dir_list]
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
