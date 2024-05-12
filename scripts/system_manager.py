#!/usr/bin/env python3

import os
import site
import subprocess
from enum import StrEnum
from pathlib import Path
from typing import List

# FIXME: I have utils that are not installed as python packages yet.
# Eventually, I should consolidate this and create a mechanism in nix to do so.
site.addsitedir(str(Path(__file__).parent))

from fzf import Fzf


class SystemActions(StrEnum):
    LOCK_SCREEN = "Lock Screen"
    QUIT_WINDOW_MANAGER = "Quit Window Manager"
    POWER_OFF = "Power Off"
    REBOOT = "Reboot"


class WindowManager(StrEnum):
    QTILE = '.qtile-wrapped'
    HERBSTLUFTWM = 'herbstluftwm'


def exec(command: List[str]) -> None:
    os.execlp(command[0], *command)


def get_running_wm() -> WindowManager:
    result = subprocess.run(["ps", "-a"], capture_output=True)
    result.check_returncode()
    # split the output over lines and skip the header line
    for row in str(result.stdout, encoding="utf-8").strip().split('\n')[1:]:
        match row.strip().split()[-1]:
            case WindowManager.HERBSTLUFTWM:
                return WindowManager.HERBSTLUFTWM
            case WindowManager.QTILE:
                return WindowManager.QTILE
    raise ValueError("Unable to identify running window manager!")


def get_wallpaper() -> Path:
    with open(Path.home() / ".fehbg", 'r') as f:
        return Path(f.readlines()[-1].strip().split(' ')[-1].replace("'", ''))


def blur_image(image: Path) -> Path:
    blurred_image = Path("/tmp/.blurred") / str(image).replace('/', '.')
    if not blurred_image.exists():
        blurred_image.parent.mkdir(parents=True, exist_ok=True)
        # FIXME: Use a native blurring algorithm?
        result = subprocess.run(
            ["convert", str(image), "-blur", "0x8", str(blurred_image)]
        )
        result.check_returncode()
    return blurred_image


def reload_gpg_agent() -> None:
    subprocess.run(
        ["gpg-connect-agent", "--no-autostart", "RELOADAGENT", "/bye"],
        capture_output=True
    ).check_returncode()


def main() -> None:
    fzf = Fzf(prompt="System Action: ", reverse=True)
    action = fzf.prompt(list(SystemActions))
    match action:
        case SystemActions.LOCK_SCREEN:
            reload_gpg_agent()
            wallpaper = get_wallpaper()
            if wallpaper.exists():
                blurred_wallpaper = blur_image(wallpaper)
                exec(["i3lock", "-tnefi", str(blurred_wallpaper)])
            else:
                exec(["i3lock", "-nef", "--color=000000"])
        case SystemActions.QUIT_WINDOW_MANAGER:
            match get_running_wm():
                case WindowManager.HERBSTLUFTWM:
                    exec(["herbstclient", "quit"])
                case WindowManager.QTILE:
                    exec(["qtile", "cmd-obj", "-o", "cmd", "-f", "shutdown"])
        case SystemActions.POWER_OFF:
            exec(["sudo", "poweroff"])
        case SystemActions.REBOOT:
            exec(["sudo", "reboot"])


if __name__ == "__main__":
    main()
