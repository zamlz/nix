"""Tests for navi.window_manager module."""

import pytest
from unittest.mock import patch

from navi.window_manager import (
    WindowManager,
    HerbstluftWM,
    NiriWM,
    Window,
    Workspace,
    get_window_manager,
    set_window_title,
)


class TestWindowManagerABC:
    """Tests for the WindowManager abstract base class."""

    def test_cannot_instantiate_abstract_class(self):
        """WindowManager should not be directly instantiable."""
        with pytest.raises(TypeError):
            WindowManager()

    def test_herbstluftwm_is_window_manager(self):
        """HerbstluftWM should be a WindowManager instance."""
        wm = HerbstluftWM()
        assert isinstance(wm, WindowManager)

    def test_niri_is_window_manager(self):
        """NiriWM should be a WindowManager instance."""
        wm = NiriWM()
        assert isinstance(wm, WindowManager)


class TestGetWindowManager:
    """Tests for get_window_manager function."""

    def test_detects_herbstluftwm(self, mock_subprocess_run):
        """Should return HerbstluftWM instance when herbstluftwm is running."""
        mock_subprocess_run.return_value.stdout = (
            b"  PID TTY          TIME CMD\n"
            b" 1234 ?        00:00:01 herbstluftwm\n"
            b" 5678 ?        00:00:00 bash\n"
        )
        result = get_window_manager()
        assert isinstance(result, HerbstluftWM)

    def test_detects_niri(self, mock_subprocess_run):
        """Should return NiriWM instance when niri-session is running."""
        mock_subprocess_run.return_value.stdout = (
            b"  PID TTY          TIME CMD\n"
            b" 1234 ?        00:00:01 niri-session\n"
            b" 5678 ?        00:00:00 bash\n"
        )
        result = get_window_manager()
        assert isinstance(result, NiriWM)

    def test_raises_on_unknown_wm(self, mock_subprocess_run):
        """Should raise ValueError if no known WM is found."""
        mock_subprocess_run.return_value.stdout = (
            b"  PID TTY          TIME CMD\n"
            b" 1234 ?        00:00:01 unknown-wm\n"
            b" 5678 ?        00:00:00 bash\n"
        )
        with pytest.raises(ValueError, match="Unable to identify"):
            get_window_manager()


class TestSetWindowTitle:
    """Tests for set_window_title function."""

    def test_prints_escape_sequence(self, capsys):
        """set_window_title should print the correct escape sequence."""
        set_window_title("Test Title")
        captured = capsys.readouterr()
        assert captured.out == '\33]0;Test Title\a'


class TestHerbstluftWM:
    """Tests for HerbstluftWM implementation."""

    def test_copy_to_clipboard_calls_xclip(self, tmp_path):
        """copy_to_clipboard should use xclip with nohup."""
        test_file = tmp_path / "test.txt"
        test_file.write_text("test content")
        wm = HerbstluftWM()

        with patch.object(wm, '_nohup') as mock_nohup:
            wm.copy_to_clipboard(test_file)
            mock_nohup.assert_called_once_with([
                "xclip", "-selection", "clipboard", str(test_file)
            ])

    def test_create_workspace_calls_herbstclient(self, mock_subprocess_run):
        """create_workspace should call herbstclient add and return workspace."""
        # First call is herbstclient add, second is wmctrl -d for list_workspaces
        def side_effect(cmd, **kwargs):
            from unittest.mock import MagicMock
            result = MagicMock()
            result.returncode = 0
            result.check_returncode = MagicMock()
            if cmd[0] == "wmctrl":
                result.stdout = b"0  * DG: N/A  VP: N/A  WA: N/A  test-workspace\n"
            else:
                result.stdout = b""
            return result
        mock_subprocess_run.side_effect = side_effect
        wm = HerbstluftWM()
        workspace = wm.create_workspace("test-workspace")
        assert workspace.name == "test-workspace"

    def test_delete_workspace_calls_herbstclient(self, mock_subprocess_run):
        """delete_workspace should call herbstclient merge_tag."""
        wm = HerbstluftWM()
        wm.delete_workspace("test-workspace")
        mock_subprocess_run.assert_called_with(["herbstclient", "merge_tag", "test-workspace"])


class TestNiriWM:
    """Tests for NiriWM implementation."""

    def test_copy_to_clipboard_calls_wl_copy(self, tmp_path, mock_subprocess_run):
        """copy_to_clipboard should use wl-copy."""
        test_file = tmp_path / "test.txt"
        test_file.write_text("test content")
        wm = NiriWM()

        wm.copy_to_clipboard(test_file)
        mock_subprocess_run.assert_called_once()
        call_args = mock_subprocess_run.call_args
        assert call_args[0][0] == ["wl-copy"]
        assert call_args[1]["input"] == "test content"

    def test_create_workspace_raises_not_implemented(self):
        """create_workspace should raise NotImplementedError for Niri."""
        wm = NiriWM()
        with pytest.raises(NotImplementedError):
            wm.create_workspace("test-workspace")

    def test_delete_workspace_raises_not_implemented(self):
        """delete_workspace should raise NotImplementedError for Niri."""
        wm = NiriWM()
        with pytest.raises(NotImplementedError):
            wm.delete_workspace("test-workspace")

    def test_list_workspaces_raises_not_implemented(self):
        """list_workspaces should raise NotImplementedError for Niri."""
        wm = NiriWM()
        with pytest.raises(NotImplementedError):
            wm.list_workspaces()

    def test_list_windows_raises_not_implemented(self):
        """list_windows should raise NotImplementedError for Niri."""
        wm = NiriWM()
        with pytest.raises(NotImplementedError):
            wm.list_windows()


class TestWorkspaceDataclass:
    """Tests for Workspace dataclass."""

    def test_workspace_str_active(self):
        """Active workspace should have blue color in str."""
        workspace = Workspace(
            id=0, active=True, geometry="1920x1080",
            viewport="0,0", workarea="0,0 1920x1080", name="test"
        )
        assert "test" in str(workspace)

    def test_workspace_str_inactive(self):
        """Inactive workspace should show name without color."""
        workspace = Workspace(
            id=1, active=False, geometry="1920x1080",
            viewport="0,0", workarea="0,0 1920x1080", name="test"
        )
        assert str(workspace) == "test"


class TestWindowDataclass:
    """Tests for Window dataclass."""

    def test_window_str_contains_id_and_title(self):
        """Window str should contain id_hex and title."""
        workspace = Workspace(
            id=0, active=True, geometry="1920x1080",
            viewport="0,0", workarea="0,0 1920x1080", name="test"
        )
        window = Window(
            id_hex="0x12345", id=74565, workspace=workspace,
            process_id=1234, wm_class="terminal", hostname="localhost",
            title="My Terminal", active=False, pwd=None
        )
        assert "0x12345" in str(window)
        assert "My Terminal" in str(window)
