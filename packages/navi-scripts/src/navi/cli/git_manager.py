#!/usr/bin/env python3

import os
import sys
from argparse import ArgumentParser
from pathlib import Path
from typing import List


import navi.system
from navi.logging import setup_main_logging
from navi.shell.colors import AnsiColor
from navi.shell.fzf import Fzf
from navi.xorg.window import set_window_title


def launch_lazygit(directory: Path) -> None:
    os.chdir(directory)
    set_window_title(f"LazyGit: {directory}")
    navi.system.execute(["lazygit"])


def git_color_if_modified(directory_str: str) -> str:
    # directory string is expected to be clean! (no ANSI color codes)
    directory = Path(directory_str)
    git_status = navi.system.git_status(Path.home() / directory)
    git_ahead_count = navi.system.git_ahead_count(Path.home() / directory)
    if git_status == '' and git_ahead_count == 0:
        return directory_str
    elif git_ahead_count > 0:
        return f"{AnsiColor.BOLD}{AnsiColor.GREEN}{directory_str}{AnsiColor.RESET}"
    else:
        return f"{AnsiColor.BOLD}{AnsiColor.RED}{directory_str}{AnsiColor.RESET}"


def get_git_directories() -> List[Path]:
    set_window_title("LazyGit: Directory Lookup")
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
        color=False,
    )
    git_dir_list = [g.replace('.git/', '') for g in git_dir_list]
    git_dir_list = [git_color_if_modified(g) for g in git_dir_list]
    selection = fzf.prompt(git_dir_list)
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
