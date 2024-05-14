#!/usr/bin/env python3

import argparse
import site
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import xorg


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("window_id", type=str)
    args = parser.parse_args()
    # infer the actual int value of the window id string
    window_id = int(args.window_id, 0)
    windows = xorg.get_active_windows()
    if window_id not in windows.keys():
        raise ValueError(f"{window_id} not found among active windows")
    xorg.display_window_info(windows[window_id])


if __name__ == "__main__":
    main()
