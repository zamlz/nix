#!/usr/bin/env python3

import os
import site
import subprocess
from enum import StrEnum
from pathlib import Path

from loguru import logger

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import navi.system
from navi.logging import setup_main_logging
from navi.shell.fzf import Fzf
from navi.xorg.window import set_window_title


class SystemActions(StrEnum):
    LOCK_SCREEN = "Lock Screen"
    QUIT_DESKTOP_SESSION = "Quit Desktop Session"
    POWER_OFF = "Power Off"
    REBOOT = "Reboot"


@setup_main_logging
def main() -> None:
    set_window_title("FZF: System Manager")
    fzf = Fzf(prompt="System Action: ", reverse=True)
    action = fzf.prompt(list(SystemActions))[0]
    match action:
        case SystemActions.LOCK_SCREEN:
            navi.system.reload_gpg_agent()
            navi.system.lock_screen(blur_screen=False)
        case SystemActions.QUIT_DESKTOP_SESSION:
            navi.system.kill_window_manager()
        case SystemActions.POWER_OFF:
            navi.system.power_off()
        case SystemActions.REBOOT:
            navi.system.reboot()


if __name__ == "__main__":
    main()
