#!/usr/bin/env python3

"""Program launcher using fzf to select from executables in PATH."""

import os
from pathlib import Path
from typing import List

from loguru import logger

import navi.system
from navi.logging import setup_main_logging
from navi.shell.fzf import Fzf
from navi.window_manager import set_window_title


def get_programs_in_path() -> List[str]:
    """Get all executable programs from PATH directories."""
    programs = []
    path_dirs = os.environ.get("PATH", "").split(":")

    for path_dir in path_dirs:
        path = Path(path_dir)
        if not path.is_dir():
            continue
        try:
            for entry in path.iterdir():
                if entry.is_file():
                    programs.append(str(entry))
        except PermissionError:
            # Skip directories we can't read
            continue

    return sorted(set(programs))


@setup_main_logging
def main() -> None:
    set_window_title("FZF: Program Launcher")
    programs = get_programs_in_path()

    fzf = Fzf(
        prompt="Program Launcher: ",
        multi=False
    )

    selection = fzf.prompt(programs)
    if selection == [""] or not selection[0]:
        logger.info("No program selected")
        return

    program = selection[0]
    logger.info(f"Launching program: {program}")
    navi.system.nohup([program])


if __name__ == "__main__":
    main()
