import logging
import os
import re
import subprocess
from dataclasses import dataclass
from enum import StrEnum
from pathlib import Path
from typing import Dict, List, Optional

from navi.xorg import xwindow
from navi.xorg.window_manager import WindowManager, get_running_wm


logger = logging.getLogger(__name__)


# FIXME: I really don't like this sort of path referencing...
NOHUP_SCRIPT = Path(__file__).parent.parent / "nohup.sh"


def execute(command: List[str]) -> None:
    os.execlp(command[0], *command)


def sudo_execute(command: List[str]) -> None:
    execute(["sudo", *command])


def nohup(command: List[str]) -> None:
    subprocess.run(
        [NOHUP_SCRIPT, *command],
    ).check_returncode()


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
            sudo_execute(["herbstclient", "quit"])
        case WindowManager.QTILE:
            sudo_execute(["qtile", "cmd-obj", "-o", "cmd", "-f", "shutdown"])


def reboot() -> None:
    sudo_execute(["reboot"])


def power_off() -> None:
    sudo_execute(["poweroff"])


#FIXME: where to put these below?


# the filesystem pointer is a special construct for keeping track of
# working directories in active windows
def get_filesystem_pointer(global_search_mode: bool) -> Path:
    if global_search_mode:
        return Path.home()
    last_focused_window_id = xwindow.get_last_focused_window_id()
    if last_focused_window_id is None:
        return Path.home()
    window_pwd = xwindow.get_pwd_of_window(last_focused_window_id)
    if window_pwd is None:
        return Path.home()
    try:
        result = subprocess.run(
            ["git", "-C", str(window_pwd), "rev-parse", "--show-toplevel"],
            capture_output=True
        )
        result.check_returncode()
        return Path(str(result.stdout, encoding="utf-8").strip())
    except subprocess.CalledProcessError:
        return window_pwd


class SearchMode(StrEnum):
    FILE = 'f'
    DIRECTORY = 'd'


def filter_hidden_items(raw_items: List[Path]) -> List[Path]:
    filtered_items = []
    for item in raw_items:
        if any(map(lambda x: x.startswith('.'), item.parts)):
            continue
        filtered_items.append(item)
    return filtered_items


def get_dir_items(
        root_dir: Path,
        mode: SearchMode,
        show_hidden: bool
) -> List[str]:
    # This is way faster than globbing from pathlib objects.
    # like extremely faster
    result = subprocess.run(
        ["find", str(root_dir), "-type", mode],
        capture_output=True
    )
    result.check_returncode()
    paths = str(result.stdout, encoding="utf-8").strip().split('\n')
    paths = sorted([
        p.replace(str(root_dir), '.', 1)
        for p in paths
    ])
    if show_hidden:
        return paths
    # A not so smart hidden path check
    # note, that this filtering should be done after removing the
    # root_dir name
    return [p for p in paths if "/." not in p]


def open_items(items: List[Path]) -> None:
    for item in items:
        logger.debug(f"opening item: {item}")
        if item.is_file():
            nohup([
                "alacritty",
                "--working-directory", item.parent,
                # So why do we not run the editor command directly?
                # Well it would work in starting the editor, but zsh startup
                # runs all the hooks for saving the window details.
                # In other words, in order for every terminal window to have
                # a window_id file generated, we must start zsh
                "--command", "zsh", "-c", f"{os.getenv('EDITOR')} {item}"
            ])
        else:
            nohup(["alacritty", "--working-directory", item])
