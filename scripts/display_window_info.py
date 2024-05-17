#!/usr/bin/env python3

import argparse
import site
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

from navi.xorg.xwindow import XorgWindow


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("window_id_hex", type=str)
    args = parser.parse_args()
    print(repr(XorgWindow.get_window_from_hex(args.window_id_hex)))


if __name__ == "__main__":
    main()
