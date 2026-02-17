#!/usr/bin/env python3

from enum import StrEnum


import navi.system
from navi.logging import setup_main_logging
from navi.shell.fzf import Fzf
from navi.window_manager import get_window_manager, set_window_title


class SystemActions(StrEnum):
    LOCK_SCREEN = "Lock Screen"
    QUIT_DESKTOP_SESSION = "Quit Desktop Session"
    POWER_OFF = "Power Off"
    REBOOT = "Reboot"


@setup_main_logging
def main() -> None:
    wm = get_window_manager()
    set_window_title("FZF: System Manager")
    fzf = Fzf(prompt="System Action: ", reverse=True)
    action = fzf.prompt(list(SystemActions))[0]
    match action:
        case SystemActions.LOCK_SCREEN:
            navi.system.reload_gpg_agent()
            wm.lock_screen(blur=False)
        case SystemActions.QUIT_DESKTOP_SESSION:
            wm.kill()
        case SystemActions.POWER_OFF:
            navi.system.power_off()
        case SystemActions.REBOOT:
            navi.system.reboot()


if __name__ == "__main__":
    main()
