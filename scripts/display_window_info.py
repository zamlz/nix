#!/usr/bin/env python3

import argparse
import logging
import site
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

from navi.logging import setup_logger
from navi.xorg.xwindow import XorgWindow


logger = logging.getLogger(__name__)


def main() -> None:
    logger.info("Getting window id hex")
    parser = argparse.ArgumentParser()
    parser.add_argument("window_id_hex", type=str)
    args = parser.parse_args()
    print(repr(XorgWindow.get_window_from_hex(args.window_id_hex)))


if __name__ == "__main__":
    setup_logger()
    main()
