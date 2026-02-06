#!/usr/bin/env python3

import argparse

from loguru import logger

from navi.logging import setup_main_logging
from navi.xorg.window import display_window_info, get_window_from_id


@setup_main_logging
def main() -> None:
    logger.info("Getting window id hex")
    parser = argparse.ArgumentParser()
    parser.add_argument("window_id", type=str)
    args = parser.parse_args()
    window = get_window_from_id(int(args.window_id, 0))
    display_window_info(window)


if __name__ == "__main__":
    main()
