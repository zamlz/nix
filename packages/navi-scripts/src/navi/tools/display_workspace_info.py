#!/usr/bin/env python3

import argparse

from loguru import logger

from navi.logging import setup_main_logging
from navi.window_manager import get_window_manager


@setup_main_logging
def main() -> None:
    logger.info("Getting desktop name")
    parser = argparse.ArgumentParser()
    parser.add_argument("workspace_name", type=str)
    args = parser.parse_args()
    workspace = get_window_manager().get_workspace(args.workspace_name)
    workspace.display_info()


if __name__ == "__main__":
    main()
