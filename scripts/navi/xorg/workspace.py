import subprocess
from dataclasses import dataclass
from typing import Dict

from navi.shell.colors import AnsiColor
from navi.xorg.window_manager import WindowManager, get_running_wm

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
        title = self.title
        if self.active:
            return f"{AnsiColor.BLUE}{title}{AnsiColor.RESET}"
        return title


def display_workspace_info(workspace: XorgWorkspace) -> None:
    raise NotImplementedError(
        f'Unable to get metadata for {workspace}'
    )


def list_workspaces() -> Dict[str, XorgWorkspace]:
    result = subprocess.run(["wmctrl", "-d"], capture_output=True)
    result.check_returncode()
    workspaces = {}
    for line in str(result.stdout, encoding="utf-8").strip().split('\n'):
        split_line = line.split(maxsplit=8)
        workspace_name = split_line[8]
        workspaces[workspace_name] = XorgWorkspace(
            desktop_num=int(split_line[0]),
            active=split_line[1] == '*',
            geometry=split_line[3],
            viewport=split_line[5],
            workarea=split_line[7],
            title=workspace_name
        )
    return workspaces


def get_workspace_from_name(workspace_name: str) -> XorgWorkspace:
    try:
        return list_workspaces()[workspace_name]
    except KeyError:
        raise ValueError(f"{workspace_name} not found in active workspaces")


def jump_to_workspace(workspace: XorgWorkspace) -> None:
    result = subprocess.run([
        "xdotool",
        "set_desktop",
        str(workspace.desktop_num)
    ])
    result.check_returncode()


def move_window_to_workspace(window_id: int, workspace: XorgWorkspace) -> None:
    result = subprocess.run([
        "xdotool",
        "set_desktop_for_window",
        str(window_id),
        str(workspace.desktop_num)
    ])
    result.check_returncode()


def create_workspace(name: str) -> XorgWorkspace:
    match get_running_wm():
        case WindowManager.HERBSTLUFTWM:
            result = subprocess.run(["herbstclient", "add", name])
            result.check_returncode()
    return list_workspaces()[name]


def delete_workspace(name: str) -> None:
    match get_running_wm():
        case WindowManager.HERBSTLUFTWM:
            result = subprocess.run(["herbstclient", "merge_tag", name])
            result.check_returncode()
