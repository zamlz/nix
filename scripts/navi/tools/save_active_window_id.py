#!/usr/bin/env python3

import logging
import site
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent.parent.parent))

from navi.logging import setup_logger
from navi.xorg.window import save_active_window_id


logger = logging.getLogger(__name__)


def main() -> None:
    save_active_window_id()


if __name__ == "__main__":
    setup_logger()
    main()
