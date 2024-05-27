#!/usr/bin/env python3

import logging
import os
import site
import subprocess
from enum import StrEnum
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import navi.system
from navi.logging import setup_logger
from navi.shell.fzf import Fzf
from navi.xorg.window import set_window_title


logger = logging.getLogger(__name__)


class SystemActions(StrEnum):
    LOCK_SCREEN = "Lock Screen"
    QUIT_WINDOW_MANAGER = "Quit Window Manager"
    POWER_OFF = "Power Off"
    REBOOT = "Reboot"


def main() -> None:
    set_window_title("FZF: System Manager")
    fzf = Fzf(prompt="System Action: ", reverse=True)
    action = fzf.prompt(list(SystemActions))[0]
    match action:
        case SystemActions.LOCK_SCREEN:
            navi.system.reload_gpg_agent()
            navi.system.lock_screen()
        case SystemActions.QUIT_WINDOW_MANAGER:
            navi.system.kill_window_manager()
        case SystemActions.POWER_OFF:
            navi.system.power_off()
        case SystemActions.REBOOT:
            navi.system.reboot()


if __name__ == "__main__":
    setup_logger()
    main()
