import subprocess

from navi.window_manager.abstract import WindowManager
from navi.window_manager.herbstluftwm import HerbstluftWM
from navi.window_manager.niri import NiriWM
from navi.window_manager.types import Window, Workspace

__all__ = [
    "WindowManager",
    "HerbstluftWM",
    "NiriWM",
    "Window",
    "Workspace",
    "get_window_manager",
    "set_window_title",
]

_WM_PROCESS_MAP = {
    'herbstluftwm': HerbstluftWM,
    'niri-session': NiriWM,
}


def get_window_manager() -> WindowManager:
    """Detect and return the appropriate WindowManager instance."""
    result = subprocess.run(["ps", "-a"], capture_output=True)
    result.check_returncode()
    for row in str(result.stdout, encoding="utf-8").strip().split('\n')[1:]:
        process_name = row.strip().split()[-1]
        if process_name in _WM_PROCESS_MAP:
            return _WM_PROCESS_MAP[process_name]()
    raise ValueError("Unable to identify running window manager!")


def set_window_title(title: str) -> None:
    """Set the terminal window title using escape sequences."""
    print(f'\33]0;{title}\a', end='', flush=True)
