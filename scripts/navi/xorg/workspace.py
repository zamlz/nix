import subprocess
from dataclasses import dataclass
from typing import List


# This file makes heavy use of wmctrl as it can interact with any window
# manager that follows the EWMH/NetWM specification
# (I think herbstluftwm and qtile are?)


@dataclass(frozen=True)
class XorgWorkspace:
    desktop_num: int
    active: bool
    geometry: str
    viewport: str
    workarea: str
    title: str

    def __str__(self) -> str:
        return f"{self.desktop_num}: {self.title}"

    def focus(self) -> None:
        result = subprocess.run(["wmctrl", "-s", str(self.desktop_num)])
        result.check_returncode()


def list_workspaces() -> List[XorgWorkspace]:
    result = subprocess.run(["wmctrl", "-d"], capture_output=True)
    result.check_returncode()
    workspaces = []
    for line in str(result.stdout, encoding="utf-8").strip().split('\n'):
        split_line = line.split(maxsplit=8)
        workspaces.append(XorgWorkspace(
            desktop_num=int(split_line[0]),
            active=split_line[1] == '*',
            geometry=split_line[3],
            viewport=split_line[5],
            workarea=split_line[7],
            title=split_line[8]
        ))
    return workspaces
