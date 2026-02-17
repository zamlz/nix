#!/usr/bin/env python3

import argparse

from loguru import logger

from navi.logging import setup_main_logging
from navi.window_manager import get_window_manager


@setup_main_logging
def main() -> None:
    logger.info("Getting window id hex")
    parser = argparse.ArgumentParser()
    parser.add_argument("window_id", type=str)
    args = parser.parse_args()
    window = get_window_manager().get_window(int(args.window_id, 0))
    window.display_info()


if __name__ == "__main__":
    main()
