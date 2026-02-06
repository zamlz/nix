from __future__ import annotations

import re
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Optional

from loguru import logger

from navi.shell.colors import AnsiColor
from navi.xorg.workspace import XorgWorkspace, list_workspaces


USER_TMP_PATH = Path.home() / "tmp"
WINDOW_ID_ENV_DIR = USER_TMP_PATH / ".wid"
LAST_SAVED_ACTIVE_WINDOW_ID_FILE= USER_TMP_PATH / ".last_active_wid"
WINDOW_PWD_REGEX = re.compile("^WINDOW_PWD='(.+)'$")


@dataclass(frozen=True)
class XorgWindow:
    window_id_hex: str
    window_id: int
    workspace: XorgWorkspace
    process_id: int
    wm_class: str
    hostname: str
    title: str
    active: bool
    pwd: Optional[Path]

    def __str__(self) -> str:
        title = f"{self.window_id_hex} {self.title}"
        if self.active:
            return f"{AnsiColor.BLUE}{title}{AnsiColor.RESET}"
        return title


def display_window_info(window: XorgWindow) -> None:
    active_wksp = " (active)" if window.workspace.active else ""
    wksp_title = window.workspace.title
    print(
        f"{AnsiColor.BOLD}WINDOW_ID{AnsiColor.RESET} = "
        f"{AnsiColor.CYAN}{window.window_id}{AnsiColor.RESET}\n"
        f"{AnsiColor.BOLD}WINDOW_ID (hex){AnsiColor.RESET} = "
        f"{AnsiColor.CYAN}{window.window_id_hex}{AnsiColor.RESET}\n"
        f"{AnsiColor.BOLD}WORKSPACE{AnsiColor.RESET} = "
        f"{AnsiColor.YELLOW}{wksp_title}{active_wksp}{AnsiColor.RESET}\n"
        f"{AnsiColor.BOLD}PROCESS_ID{AnsiColor.RESET} = "
        f"{AnsiColor.RED}{window.process_id}{AnsiColor.RESET}\n"
        f"{AnsiColor.BOLD}CLASS{AnsiColor.RESET} = "
        f"{AnsiColor.MAGENTA}{window.wm_class}{AnsiColor.RESET}\n"
        f"{AnsiColor.BOLD}TITLE{AnsiColor.RESET} = "
        f"{AnsiColor.GREEN}{window.title}{AnsiColor.RESET}\n"
        f"{AnsiColor.BOLD}WINDOW_PWD{AnsiColor.RESET} = "
        f"{AnsiColor.BLUE}{window.pwd}{AnsiColor.RESET}"
    )


def get_active_windows(filter_on_id: Optional[int] = None) -> Dict[int ,XorgWindow]:
    active_windows = {}
    last_active_window_id = get_last_active_window_id()
    workspaces = {w.desktop_num: w for w in list_workspaces().values()}
    result = subprocess.run(["wmctrl", "-lxp"], capture_output=True)
    result.check_returncode()
    for line in str(result.stdout, encoding="utf-8").strip().split("\n"):
        wmctrl_val = line.strip().split(maxsplit=5)
        # infer the actual int value of the window id string
        window_id = int(wmctrl_val[0], 0)
        if filter_on_id is not None and filter_on_id != window_id:
            continue
        active_windows[window_id] = XorgWindow(
            window_id_hex = wmctrl_val[0],
            window_id = window_id,
            workspace = workspaces[int(wmctrl_val[1])],
            process_id = int(wmctrl_val[2]),
            wm_class = wmctrl_val[3],
            hostname = wmctrl_val[4],
            title = wmctrl_val[5],
            active = last_active_window_id == window_id,
            pwd = get_pwd_of_window(window_id)
        )
    return active_windows


def get_window_from_id(window_id: int) -> XorgWindow:
    filtered_windows = get_active_windows(filter_on_id=window_id)
    if len(filtered_windows) == 0:
        raise ValueError(f"{window_id} not found among active windows")
    return list(filtered_windows.values())[0]


def focus_window(window_id: int) -> None:
    # So why am I running both of these comands here?
    # Changing window focus sometimes means we have to change the workspace
    # we are in. wmctrl does that effectively, but has trouble when dealing
    # with herbstluftwm's frames. xdotool on the other hand can handle
    # this, but it cannot handle workspaces. A combination of both is run
    # to make sure we are effectively changing focus to the window
    subprocess.run(["wmctrl", "-i", "-a", hex(window_id)])
    subprocess.run(["xdotool", "windowfocus", hex(window_id)])


def get_pwd_of_window(window_id: int) -> Optional[Path]:
    window_id_file = WINDOW_ID_ENV_DIR / f"{window_id}"
    if not window_id_file.exists():
        logger.debug('no window id file found')
        return None
    with open(window_id_file, 'r') as f:
        for line in f.readlines():
            match = re.match(WINDOW_PWD_REGEX, line)
            if match is not None:
                return Path(match.group(1))
    raise ValueError(
        f"Found window id file for {window_id} but no pwd was found!"
    )


def save_active_window_id() -> None:
    with open(LAST_SAVED_ACTIVE_WINDOW_ID_FILE, 'w') as f:
        result = subprocess.run(["xdotool", "getactivewindow"], stdout=f)
        result.check_returncode()


def get_last_active_window_id() -> Optional[int]:
    if not LAST_SAVED_ACTIVE_WINDOW_ID_FILE.exists():
        return None
    with open(LAST_SAVED_ACTIVE_WINDOW_ID_FILE, 'r') as f:
        if (data := f.read().strip()) == '':
            return None
        return int(data)


def set_window_title(title: str) -> None:
    print(f'\33]0;{title}\a', end='', flush=True)
