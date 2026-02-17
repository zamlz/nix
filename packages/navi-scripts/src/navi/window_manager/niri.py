import json
import re
import subprocess
from pathlib import Path
from typing import Dict, Optional

from loguru import logger

from navi.window_manager.abstract import WindowManager
from navi.window_manager.types import Window, Workspace


USER_TMP_PATH = Path.home() / "tmp"
WINDOW_ID_ENV_DIR = USER_TMP_PATH / ".wid"
LAST_SAVED_ACTIVE_WINDOW_ID_FILE = USER_TMP_PATH / ".last_active_wid"
WINDOW_PWD_REGEX = re.compile("^WINDOW_PWD='(.+)'$")


class NiriWM(WindowManager):
    """Window manager implementation for Niri (Wayland)."""

    # Clipboard
    def copy_to_clipboard(self, file_path: Path) -> None:
        with open(file_path, 'r') as f:
            subprocess.run(["wl-copy"], input=f.read(), text=True).check_returncode()

    # Screen lock
    def lock_screen(self, blur: bool) -> None:
        self._execute(["swaylock"])

    # Session management
    def kill(self) -> None:
        self._execute(["niri", "msg", "action", "quit"])

    # Workspace operations
    def list_workspaces(self) -> Dict[str, Workspace]:
        result = subprocess.run(
            ["niri", "msg", "--json", "workspaces"],
            capture_output=True
        )
        result.check_returncode()
        workspaces_data = json.loads(result.stdout)

        workspaces = {}
        for ws in workspaces_data:
            # Use name if available, otherwise use index as string
            ws_name = ws.get("name") or str(ws["idx"])
            workspaces[ws_name] = Workspace(
                id=ws["idx"],
                active=ws.get("is_active", False) or ws.get("is_focused", False),
                geometry="N/A",
                viewport="N/A",
                workarea="N/A",
                name=ws_name
            )
        return workspaces

    def get_workspace(self, name: str) -> Workspace:
        workspaces = self.list_workspaces()
        if name in workspaces:
            return workspaces[name]
        # Try matching by index
        for ws in workspaces.values():
            if str(ws.id) == name:
                return ws
        raise ValueError(f"{name} not found in active workspaces")

    def create_workspace(self, name: str) -> Workspace:
        raise NotImplementedError(
            "Niri uses dynamic workspaces - they are created automatically "
            "when moving windows to new workspace indices"
        )

    def delete_workspace(self, name: str) -> None:
        raise NotImplementedError(
            "Niri automatically removes empty workspaces"
        )

    def jump_to_workspace(self, workspace: Workspace) -> None:
        # Use workspace name if available, otherwise use index
        ref = workspace.name if workspace.name else str(workspace.id)
        result = subprocess.run(["niri", "msg", "action", "focus-workspace", ref])
        result.check_returncode()

    def move_window_to_workspace(self, window_id: int, workspace: Workspace) -> None:
        ref = workspace.name if workspace.name else str(workspace.id)
        result = subprocess.run([
            "niri", "msg", "action", "move-window-to-workspace",
            "--window-id", str(window_id), ref
        ])
        result.check_returncode()

    # Window operations
    def list_windows(self, filter_id: Optional[int] = None) -> Dict[int, Window]:
        result = subprocess.run(
            ["niri", "msg", "--json", "windows"],
            capture_output=True
        )
        result.check_returncode()
        windows_data = json.loads(result.stdout)

        # Build workspace lookup
        workspaces_by_id = {}
        for ws in self.list_workspaces().values():
            # Niri workspace id in windows is the internal id, not idx
            # We need to re-fetch to get the mapping
            pass

        # Re-fetch workspaces with internal ids
        ws_result = subprocess.run(
            ["niri", "msg", "--json", "workspaces"],
            capture_output=True
        )
        ws_result.check_returncode()
        ws_data = json.loads(ws_result.stdout)
        for ws in ws_data:
            ws_name = ws.get("name") or str(ws["idx"])
            workspaces_by_id[ws["id"]] = Workspace(
                id=ws["idx"],
                active=ws.get("is_active", False) or ws.get("is_focused", False),
                geometry="N/A",
                viewport="N/A",
                workarea="N/A",
                name=ws_name
            )

        windows = {}
        for win in windows_data:
            win_id = win["id"]
            if filter_id is not None and filter_id != win_id:
                continue

            # Get workspace for this window
            ws_id = win.get("workspace_id")
            workspace = workspaces_by_id.get(ws_id) if ws_id else None
            if workspace is None:
                # Create a placeholder workspace for floating/unassigned windows
                workspace = Workspace(
                    id=0,
                    active=False,
                    geometry="N/A",
                    viewport="N/A",
                    workarea="N/A",
                    name="floating"
                )

            windows[win_id] = Window(
                id_hex=hex(win_id),
                id=win_id,
                workspace=workspace,
                process_id=win.get("pid") or 0,
                wm_class=win.get("app_id") or "",
                hostname="",
                title=win.get("title") or "",
                active=win.get("is_focused", False),
                pwd=self.get_window_pwd(win_id)
            )
        return windows

    def get_window(self, window_id: int) -> Window:
        filtered_windows = self.list_windows(filter_id=window_id)
        if len(filtered_windows) == 0:
            raise ValueError(f"{window_id} not found among active windows")
        return list(filtered_windows.values())[0]

    def focus_window(self, window_id: int) -> None:
        result = subprocess.run([
            "niri", "msg", "action", "focus-window", "--id", str(window_id)
        ])
        result.check_returncode()

    def get_last_active_window_id(self) -> Optional[int]:
        # First try the saved file (for consistency with shell hooks)
        if LAST_SAVED_ACTIVE_WINDOW_ID_FILE.exists():
            with open(LAST_SAVED_ACTIVE_WINDOW_ID_FILE, 'r') as f:
                if (data := f.read().strip()) != '':
                    return int(data)

        # Fall back to currently focused window
        result = subprocess.run(
            ["niri", "msg", "--json", "focused-window"],
            capture_output=True
        )
        if result.returncode != 0:
            return None
        try:
            data = json.loads(result.stdout)
            if data and "id" in data:
                return data["id"]
        except json.JSONDecodeError:
            pass
        return None

    def save_active_window_id(self) -> None:
        result = subprocess.run(
            ["niri", "msg", "--json", "focused-window"],
            capture_output=True
        )
        if result.returncode != 0:
            return

        try:
            data = json.loads(result.stdout)
            if data and "id" in data:
                LAST_SAVED_ACTIVE_WINDOW_ID_FILE.parent.mkdir(parents=True, exist_ok=True)
                with open(LAST_SAVED_ACTIVE_WINDOW_ID_FILE, 'w') as f:
                    f.write(str(data["id"]))
        except json.JSONDecodeError:
            logger.warning("Failed to parse focused window response")

    def get_window_pwd(self, window_id: int) -> Optional[Path]:
        # Uses the same file-based tracking as HerbstluftWM
        # This is populated by shell hooks, not by the WM
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
