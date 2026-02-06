"""Tests for navi.window_manager module."""

import pytest

from navi.window_manager import WindowManager, get_running_wm


class TestWindowManagerEnum:
    """Tests for the WindowManager enum."""

    def test_herbstluftwm_value(self):
        """HERBSTLUFTWM should match the process name."""
        assert WindowManager.HERBSTLUFTWM == "herbstluftwm"

    def test_niri_value(self):
        """NIRI should match the niri-session process name."""
        assert WindowManager.NIRI == "niri-session"


class TestGetRunningWm:
    """Tests for get_running_wm function."""

    def test_detects_herbstluftwm(self, mock_subprocess_run):
        """Should detect herbstluftwm from ps output."""
        mock_subprocess_run.return_value.stdout = (
            b"  PID TTY          TIME CMD\n"
            b" 1234 ?        00:00:01 herbstluftwm\n"
            b" 5678 ?        00:00:00 bash\n"
        )
        result = get_running_wm()
        assert result == WindowManager.HERBSTLUFTWM

    def test_detects_niri(self, mock_subprocess_run):
        """Should detect niri-session from ps output."""
        mock_subprocess_run.return_value.stdout = (
            b"  PID TTY          TIME CMD\n"
            b" 1234 ?        00:00:01 niri-session\n"
            b" 5678 ?        00:00:00 bash\n"
        )
        result = get_running_wm()
        assert result == WindowManager.NIRI

    def test_raises_on_unknown_wm(self, mock_subprocess_run):
        """Should raise ValueError if no known WM is found."""
        mock_subprocess_run.return_value.stdout = (
            b"  PID TTY          TIME CMD\n"
            b" 1234 ?        00:00:01 unknown-wm\n"
            b" 5678 ?        00:00:00 bash\n"
        )
        with pytest.raises(ValueError, match="Unable to identify"):
            get_running_wm()
