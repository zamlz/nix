#!/usr/bin/env python3

import logging
import os
import site
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import navi.system
from navi.logging import setup_logger
from navi.xorg import xwindow


logger = logging.getLogger(__name__)


def main() -> None:
    filesystem_pointer = navi.system.get_filesystem_pointer(False)
    os.chdir(filesystem_pointer)
    xwindow.set_window_title(f"LazyGit: {filesystem_pointer}")
    navi.system.execute(["lazygit"])


if __name__ == "__main__":
    setup_logger()
    main()
