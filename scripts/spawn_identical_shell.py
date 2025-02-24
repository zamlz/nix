#!/usr/bin/env python3

# TODO: Eventually integrate this with a symbolic math library

import site
import os
from pathlib import Path

from loguru import logger

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import navi.system
from navi.logging import setup_main_logging


@setup_main_logging
def main() -> None:
    fs_ptr = navi.system.get_filesystem_pointer(global_search_mode=False, find_git_root=False)
    os.chdir(str(fs_ptr.absolute()))
    navi.system.execute([os.environ["SHELL"]])


if __name__ == "__main__":
    main()
