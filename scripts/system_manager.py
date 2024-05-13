#!/usr/bin/env python3

import os
import site
import subprocess
from enum import StrEnum
from pathlib import Path

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

import ps
import xorg
from fzf import Fzf
from xorg import WindowManager


class SystemActions(StrEnum):
    LOCK_SCREEN = "Lock Screen"
    QUIT_WINDOW_MANAGER = "Quit Window Manager"
    POWER_OFF = "Power Off"
    REBOOT = "Reboot"


def reload_gpg_agent() -> None:
    subprocess.run(
        ["gpg-connect-agent", "--no-autostart", "RELOADAGENT", "/bye"],
        capture_output=True
    ).check_returncode()


def main() -> None:
    xorg.set_window_title("FZF: System Manager")
    fzf = Fzf(prompt="System Action: ", reverse=True)
    action = fzf.prompt(list(SystemActions))
    match action:
        case SystemActions.LOCK_SCREEN:
            reload_gpg_agent()
            xorg.lock_screen()
        case SystemActions.QUIT_WINDOW_MANAGER:
            xorg.kill_window_manager()
        case SystemActions.POWER_OFF:
            ps.exec(["sudo", "poweroff"])
        case SystemActions.REBOOT:
            ps.exec(["sudo", "reboot"])


if __name__ == "__main__":
    main()
