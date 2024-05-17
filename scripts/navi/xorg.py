import re
import subprocess
from dataclasses import dataclass
from enum import StrEnum
from pathlib import Path
from typing import Dict, List, Optional

from . import process
from .colors import AnsiColor


WINDOW_ID_ENV_DIR = Path("/tmp/.wid")
LAST_FOCUSED_WINDOW_ID_FILE = Path("/tmp/.last_focused_wid")
WINDOW_PWD_REGEX = re.compile("^WINDOW_PWD='(.+)'$")


class WindowManager(StrEnum):
    # This is the name of the process from `ps`
    QTILE = '.qtile-wrapped'
    HERBSTLUFTWM = 'herbstluftwm'


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

    def __str__(self) -> str:
        return f"{self.window_id_hex} {self.title}"


def display_window_info(window: XorgWindow) -> None:
    print(
        f"{AnsiColor.BOLD}WINDOW_ID{AnsiColor.RESET} = "
        f"{AnsiColor.CYAN}{window.window_id}{AnsiColor.RESET}"
    )
    print(
        f"{AnsiColor.BOLD}WINDOW_ID (hex){AnsiColor.RESET} = "
        f"{AnsiColor.CYAN}{window.window_id_hex}{AnsiColor.RESET}"
    )
    print(
        f"{AnsiColor.BOLD}WORKSPACE_ID{AnsiColor.RESET} = "
        f"{AnsiColor.YELLOW}{window.workspace}{AnsiColor.RESET}"
    )
    print(
        f"{AnsiColor.BOLD}PROCESS_ID{AnsiColor.RESET} = "
        f"{AnsiColor.RED}{window.process_id}{AnsiColor.RESET}"
    )
    print(
        f"{AnsiColor.BOLD}CLASS{AnsiColor.RESET} = "
        f"{AnsiColor.MAGENTA}{window.wm_class}{AnsiColor.RESET}"
    )
    print(
        f"{AnsiColor.BOLD}TITLE{AnsiColor.RESET} = "
        f"{AnsiColor.GREEN}{window.title}{AnsiColor.RESET}"
    )
    if window.pwd is not None:
        print(
            f"{AnsiColor.BOLD}WINDOW_PWD{AnsiColor.RESET} = "
            f"{AnsiColor.BLUE}{window.pwd}{AnsiColor.RESET}"
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
        return int(f.read().strip())


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


def get_active_windows() -> Dict[int ,XorgWindow]:
    result = subprocess.run(["wmctrl", "-lxp"], capture_output=True)
    result.check_returncode()
    windows = {}
    for row in str(result.stdout, encoding="utf-8").strip().split("\n"):
        extracted_values = row.strip().split(maxsplit=5)
        # infer the actual int value of the window id string
        window_id = int(extracted_values[0], 0)
        windows[window_id] = XorgWindow(
            window_id_hex = extracted_values[0],
            window_id = window_id,
            workspace = int(extracted_values[1]),
            process_id = int(extracted_values[2]),
            wm_class = extracted_values[3],
            hostname = extracted_values[4],
            title = extracted_values[5],
            pwd = get_pwd_of_window(window_id)
        )
    return windows


def focus_window(window: XorgWindow) -> None:
    # So why am I running both of these comands here?
    # Changing window focus sometimes means we have to change the workspace we
    # are in. wmctrl does that effectively, but has trouble when dealing with
    # herbstluftwm's frames. xdotool on the other hand can handle this, but
    # it cannot handle workspaces. A combination of both is run to make sure
    # we are effectively changing focus to the window
    subprocess.run(["wmctrl", "-i", "-a", window.window_id_hex])
    subprocess.run(["xdotool", "windowfocus", window.window_id_hex])


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


def kill_window_manager() -> None:
    match get_running_wm():
        case WindowManager.HERBSTLUFTWM:
            process.exec(["herbstclient", "quit"])
        case WindowManager.QTILE:
            process.exec(["qtile", "cmd-obj", "-o", "cmd", "-f", "shutdown"])


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
        process.exec(["i3lock", "-tnefi", str(blurred_wallpaper)])
    else:
        process.exec(["i3lock", "-nef", "--color=000000"])


def set_window_title(title: str) -> None:
    print(f'\33]0;{title}\a', end='', flush=True)


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


if __name__ == "__main__":
    print(get_dir_items(Path.home(), SearchMode.DIRECTORY))
