import os
import subprocess
from abc import ABC, abstractmethod
from pathlib import Path
from typing import Dict, List, Mapping, Optional

from navi.window_manager.types import Window, Workspace


class WindowManager(ABC):
    """Abstract base class for window manager implementations."""

    # Clipboard
    @abstractmethod
    def copy_to_clipboard(self, file_path: Path) -> None:
        """Copy file contents to the system clipboard."""
        pass

    # Screen lock
    @abstractmethod
    def lock_screen(self, blur: bool) -> None:
        """Lock the screen, optionally with a blurred background."""
        pass

    # Session management
    @abstractmethod
    def kill(self) -> None:
        """Quit the window manager."""
        pass

    # Workspace operations
    @abstractmethod
    def list_workspaces(self) -> Dict[str, Workspace]:
        """List all workspaces."""
        pass

    @abstractmethod
    def get_workspace(self, name: str) -> Workspace:
        """Get a workspace by name."""
        pass

    @abstractmethod
    def create_workspace(self, name: str) -> Workspace:
        """Create a new workspace with the given name."""
        pass

    @abstractmethod
    def delete_workspace(self, name: str) -> None:
        """Delete the workspace with the given name."""
        pass

    @abstractmethod
    def jump_to_workspace(self, workspace: Workspace) -> None:
        """Switch to the given workspace."""
        pass

    @abstractmethod
    def move_window_to_workspace(self, window_id: int, workspace: Workspace) -> None:
        """Move a window to the given workspace."""
        pass

    # Window operations
    @abstractmethod
    def list_windows(self, filter_id: Optional[int] = None) -> Dict[int, Window]:
        """List all windows, optionally filtered by window ID."""
        pass

    @abstractmethod
    def get_window(self, window_id: int) -> Window:
        """Get a window by ID."""
        pass

    @abstractmethod
    def focus_window(self, window_id: int) -> None:
        """Focus the given window."""
        pass

    @abstractmethod
    def get_last_active_window_id(self) -> Optional[int]:
        """Get the ID of the last active window."""
        pass

    @abstractmethod
    def save_active_window_id(self) -> None:
        """Save the current active window ID."""
        pass

    @abstractmethod
    def get_window_pwd(self, window_id: int) -> Optional[Path]:
        """Get the working directory of a window."""
        pass

    @abstractmethod
    def get_focused_window_id(self) -> Optional[int]:
        """Get the ID of the currently focused window."""
        pass

    @abstractmethod
    def save_window_pwd(self, window_id: int, pwd: Path) -> None:
        """Save the working directory for a window."""
        pass

    # Terminal spawning
    @abstractmethod
    def spawn_terminal(
        self,
        command: Optional[List[str]] = None,
        working_dir: Optional[Path] = None,
        app_id: Optional[str] = None,
        lines: Optional[int] = None,
        columns: Optional[int] = None,
        font_size: Optional[float] = None,
    ) -> None:
        """Spawn a terminal window with optional customization.

        Args:
            command: Command to execute in the terminal
            working_dir: Working directory for the terminal
            app_id: Window class/app-id for window manager rules
            lines: Number of lines (height) for the terminal window
            columns: Number of columns (width) for the terminal window
            font_size: Font size (already scaled by fontScale from Nix)
        """
        pass

    # Utility methods shared by implementations
    @staticmethod
    def _execute(command: List[str], environ: Mapping[str, str] = os.environ) -> None:
        os.execlpe(command[0], *command, dict(environ))

    @staticmethod
    def _sudo_execute(command: List[str]) -> None:
        WindowManager._execute(["sudo", *command])

    @staticmethod
    def _nohup(command: List[str]) -> None:
        from navi.data import get_data_script_path
        nohup_script = get_data_script_path("nohup.sh")
        subprocess.run([nohup_script, *command]).check_returncode()
