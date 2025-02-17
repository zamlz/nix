#!/usr/bin/env python3

import site
from pathlib import Path

from loguru import logger

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent.parent.parent))

from navi.logging import setup_main_logging
from navi.xorg.window import save_active_window_id


@setup_main_logging
def main() -> None:
    save_active_window_id()


if __name__ == "__main__":
    main()
