"""Pytest configuration and fixtures."""

import pytest
from unittest.mock import MagicMock, patch


@pytest.fixture
def mock_subprocess_run():
    """Mock subprocess.run for tests that don't need actual command execution."""
    with patch("subprocess.run") as mock:
        mock.return_value = MagicMock(
            returncode=0,
            stdout=b"",
            stderr=b""
        )
        mock.return_value.check_returncode = MagicMock()
        yield mock


@pytest.fixture
def mock_fzf_prompt():
    """Mock Fzf.prompt to avoid interactive fzf calls."""
    with patch("navi.shell.fzf.Fzf.prompt") as mock:
        yield mock
