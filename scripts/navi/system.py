import os
import re
import subprocess
from dataclasses import dataclass
from enum import StrEnum
from pathlib import Path
from typing import Dict, List, Optional

from navi.xorg.window_manager import WindowManager, get_running_wm


def execute(command: List[str]) -> None:
    os.execlp(command[0], *command)


def reload_gpg_agent() -> None:
    subprocess.run(
        ["gpg-connect-agent", "--no-autostart", "RELOADAGENT", "/bye"],
        capture_output=True
    ).check_returncode()


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


def lock_screen() -> None:
    wallpaper = get_wallpaper()
    if wallpaper.exists():
        blurred_wallpaper = blur_image(wallpaper)
        execute(["i3lock", "-tnefi", str(blurred_wallpaper)])
    else:
        execute(["i3lock", "-nef", "--color=000000"])


# NOTE: I'm not totally convinced this should be here
def kill_window_manager() -> None:
    match get_running_wm():
        case WindowManager.HERBSTLUFTWM:
            execute(["herbstclient", "quit"])
        case WindowManager.QTILE:
            execute(["qtile", "cmd-obj", "-o", "cmd", "-f", "shutdown"])


#FIXME: where to put these below?


# the filesystem pointer is a special construct for keeping track of
# working directories in active windows
def get_filesystem_pointer(global_search_mode: bool) -> Path:
    if global_search_mode:
        return Path.home()
    last_focused_window_id = get_last_focused_window_id()
    if last_focused_window_id is None:
        return Path.home()
    window_pwd = get_pwd_of_window(last_focused_window_id)
    # FIXME: convert it to git path
    return window_pwd


class SearchMode(StrEnum):
    FILE = 'f'
    DIRECTORY = 'd'


def get_dir_items(root_dir: Path, mode: SearchMode) -> List[str]:
    result = subprocess.run(
        ["find", str(root_dir), "-not", "-path", "'*/.*'", "-type", mode],
        capture_output=True
    )
    result.check_returncode()
    paths = str(result.stdout, encoding="utf-8").strip().split("\n")
    return [p.replace(str(root_dir), ".") for p in paths]
