from __future__ import annotations

import re
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Optional

from navi.shell.colors import AnsiColor


WINDOW_ID_ENV_DIR = Path("/tmp/.wid")
LAST_FOCUSED_WINDOW_ID_FILE = Path("/tmp/.last_focused_wid")
WINDOW_PWD_REGEX = re.compile("^WINDOW_PWD='(.+)'$")


@dataclass(frozen=True)
class XorgWindow:
    window_id_hex: str
    window_id: int
    workspace: int
    process_id: int
    wm_class: str
    hostname: str
    title: str
    pwd: Optional[Path]

    @staticmethod
    def _get_wmctrl_output() -> Iterator[str]:
        result = subprocess.run(["wmctrl", "-lxp"], capture_output=True)
        result.check_returncode()
        for line in str(result.stdout, encoding="utf-8").strip().split("\n"):
            yield line

    @classmethod
    def get_active_windows(
            cls,
            filter_on_hex: Optional[str] = None
    ) -> Dict[int ,XorgWindow]:
        active_windows = {}
        for row in cls._get_wmctrl_output():
            wmctrl_val = row.strip().split(maxsplit=5)
            if filter_on_hex is not None and filter_on_hex != wmctrl_val[0]:
                continue
            # infer the actual int value of the window id string
            window_id = int(wmctrl_val[0], 0)
            active_windows[window_id] = cls(
                window_id_hex = wmctrl_val[0],
                window_id = window_id,
                workspace = int(wmctrl_val[1]),
                process_id = int(wmctrl_val[2]),
                wm_class = wmctrl_val[3],
                hostname = wmctrl_val[4],
                title = wmctrl_val[5],
                pwd = get_pwd_of_window(window_id)
            )
        return active_windows

    @classmethod
    def get_window_from_hex(cls, window_id_hex: str) -> XorgWindow:
        filtered_windows = cls.get_active_windows(filter_on_hex=window_id_hex)
        if len(filtered_windows) == 0:
            raise ValueError(f"{window_id_hex} not found among active windows")
        return list(filtered_windows.values())[0]

    def __str__(self) -> str:
        return f"{self.window_id_hex} {self.title}"

    def focus(self) -> None:
        # So why am I running both of these comands here?
        # Changing window focus sometimes means we have to change the workspace
        # we are in. wmctrl does that effectively, but has trouble when dealing
        # with herbstluftwm's frames. xdotool on the other hand can handle
        # this, but it cannot handle workspaces. A combination of both is run
        # to make sure we are effectively changing focus to the window
        subprocess.run(["wmctrl", "-i", "-a", self.window_id_hex])
        subprocess.run(["xdotool", "windowfocus", self.window_id_hex])

    def __repr__(self) -> str:
        return (
            f"{AnsiColor.BOLD}WINDOW_ID{AnsiColor.RESET} = "
            f"{AnsiColor.CYAN}{self.window_id}{AnsiColor.RESET}\n"
            f"{AnsiColor.BOLD}WINDOW_ID (hex){AnsiColor.RESET} = "
            f"{AnsiColor.CYAN}{self.window_id_hex}{AnsiColor.RESET}\n"
            f"{AnsiColor.BOLD}WORKSPACE_ID{AnsiColor.RESET} = "
            f"{AnsiColor.YELLOW}{self.workspace}{AnsiColor.RESET}\n"
            f"{AnsiColor.BOLD}PROCESS_ID{AnsiColor.RESET} = "
            f"{AnsiColor.RED}{self.process_id}{AnsiColor.RESET}\n"
            f"{AnsiColor.BOLD}CLASS{AnsiColor.RESET} = "
            f"{AnsiColor.MAGENTA}{self.wm_class}{AnsiColor.RESET}\n"
            f"{AnsiColor.BOLD}TITLE{AnsiColor.RESET} = "
            f"{AnsiColor.GREEN}{self.title}{AnsiColor.RESET}\n"
            f"{AnsiColor.BOLD}WINDOW_PWD{AnsiColor.RESET} = "
            f"{AnsiColor.BLUE}{self.pwd}{AnsiColor.RESET}"
        )


def get_pwd_of_window(window_id: int) -> Optional[Path]:
    window_id_file = WINDOW_ID_ENV_DIR / f"{window_id}"
    if not window_id_file.exists():
        return None
    with open(window_id_file, 'r') as f:
        for line in f.readlines():
            match = re.match(WINDOW_PWD_REGEX, line)
            if match is not None:
                return Path(match.group(1))
    raise ValueError(
        f"Found window id file for {window_id} but no pwd was found!"
    )


def get_last_focused_window_id() -> Optional[int]:
    if not LAST_FOCUSED_WINDOW_ID_FILE.exists():
        return None
    with open(LAST_FOCUSED_WINDOW_ID_FILE, 'r') as f:
        if (data := f.read().strip()) == '':
            return None
        return int(data)


def set_window_title(title: str) -> None:
    print(f'\33]0;{title}\a', end='', flush=True)
