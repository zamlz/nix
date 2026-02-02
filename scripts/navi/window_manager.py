import re
import subprocess
from enum import StrEnum
from pathlib import Path
from typing import Dict, List, Optional


class WindowManager(StrEnum):
    # This is the name of the process from `ps`
    HERBSTLUFTWM = 'herbstluftwm'
    NIRI = 'niri-session'


def get_running_wm() -> WindowManager:
    result = subprocess.run(["ps", "-a"], capture_output=True)
    result.check_returncode()
    # split the output over lines and skip the header line
    for row in str(result.stdout, encoding="utf-8").strip().split('\n')[1:]:
        match row.strip().split()[-1]:
            case WindowManager.HERBSTLUFTWM:
                return WindowManager.HERBSTLUFTWM
            case WindowManager.NIRI:
                return WindowManager.NIRI
    raise ValueError("Unable to identify running window manager!")
