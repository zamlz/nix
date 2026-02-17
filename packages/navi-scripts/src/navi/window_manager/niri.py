import subprocess
from pathlib import Path
from typing import Dict, Optional

from navi.window_manager.abstract import WindowManager
from navi.window_manager.types import Window, Workspace


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
        raise NotImplementedError("Niri workspace listing not yet implemented")

    def get_workspace(self, name: str) -> Workspace:
        raise NotImplementedError("Niri workspace retrieval not yet implemented")

    def create_workspace(self, name: str) -> Workspace:
        raise NotImplementedError("Niri does not support named workspace creation")

    def delete_workspace(self, name: str) -> None:
        raise NotImplementedError("Niri does not support named workspace deletion")

    def jump_to_workspace(self, workspace: Workspace) -> None:
        raise NotImplementedError("Niri workspace jumping not yet implemented")

    def move_window_to_workspace(self, window_id: int, workspace: Workspace) -> None:
        raise NotImplementedError("Niri window moving not yet implemented")

    # Window operations
    def list_windows(self, filter_id: Optional[int] = None) -> Dict[int, Window]:
        raise NotImplementedError("Niri window listing not yet implemented")

    def get_window(self, window_id: int) -> Window:
        raise NotImplementedError("Niri window retrieval not yet implemented")

    def focus_window(self, window_id: int) -> None:
        raise NotImplementedError("Niri window focusing not yet implemented")

    def get_last_active_window_id(self) -> Optional[int]:
        raise NotImplementedError("Niri active window tracking not yet implemented")

    def save_active_window_id(self) -> None:
        raise NotImplementedError("Niri active window tracking not yet implemented")

    def get_window_pwd(self, window_id: int) -> Optional[Path]:
        raise NotImplementedError("Niri window pwd not yet implemented")
