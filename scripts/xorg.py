import subprocess
from dataclasses import dataclass
from typing import Dict


@dataclass(frozen=True)
class XorgWindow:
    window_id_hex: str
    window_id: int
    workspace: int
    process_id: int
    wm_class: str
    hostname: str
    title: str

    def __str__(self) -> str:
        return f"{self.window_id_hex} {self.title}"


def get_active_windows() -> Dict[int ,XorgWindow]:
    result = subprocess.run(["wmctrl", "-lxp"], capture_output=True)
    result.check_returncode()
    windows = {}
    for row in str(result.stdout, encoding="utf-8").strip().split("\n"):
        extracted_values = row.strip().split(maxsplit=5)
        windows[extracted_values[0]] = XorgWindow(
            window_id_hex = extracted_values[0],
            window_id = int(extracted_values[0], 0),
            workspace = int(extracted_values[1]),
            process_id = int(extracted_values[2]),
            wm_class = extracted_values[3],
            hostname = extracted_values[4],
            title = extracted_values[5]
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


def set_window_title(title: str) -> None:
    print(f'\33]0;{title}\a', end='', flush=True)


if __name__ == "__main__":
    print(get_active_windows())
