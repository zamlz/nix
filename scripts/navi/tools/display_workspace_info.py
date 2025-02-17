#!/usr/bin/env python3

import argparse
import site
from pathlib import Path

from loguru import logger

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent.parent.parent))

from navi.logging import setup_main_logging
from navi.xorg.workspace import display_workspace_info, get_workspace_from_name


@setup_main_logging
def main() -> None:
    logger.info("Getting desktop name")
    parser = argparse.ArgumentParser()
    parser.add_argument("workspace_name", type=str)
    args = parser.parse_args()
    workspace = get_workspace_from_name(args.workspace_name)
    display_workspace_info(workspace)


if __name__ == "__main__":
    main()
