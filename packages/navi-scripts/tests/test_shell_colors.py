"""Tests for navi.shell.colors module."""

from navi.shell.colors import AnsiColor


class TestAnsiColor:
    """Tests for the AnsiColor enum."""

    def test_reset_value(self):
        """RESET should be the standard ANSI reset code."""
        assert AnsiColor.RESET == "\033[0m"

    def test_basic_colors_exist(self):
        """Basic colors should be defined."""
        assert hasattr(AnsiColor, "BLACK")
        assert hasattr(AnsiColor, "RED")
        assert hasattr(AnsiColor, "GREEN")
        assert hasattr(AnsiColor, "YELLOW")
        assert hasattr(AnsiColor, "BLUE")
        assert hasattr(AnsiColor, "MAGENTA")
        assert hasattr(AnsiColor, "CYAN")
        assert hasattr(AnsiColor, "GRAY")

    def test_light_colors_exist(self):
        """Light color variants should be defined."""
        assert hasattr(AnsiColor, "LIGHT_BLACK")
        assert hasattr(AnsiColor, "LIGHT_RED")
        assert hasattr(AnsiColor, "LIGHT_GREEN")
        assert hasattr(AnsiColor, "LIGHT_YELLOW")
        assert hasattr(AnsiColor, "LIGHT_BLUE")
        assert hasattr(AnsiColor, "LIGHT_MAGENTA")
        assert hasattr(AnsiColor, "LIGHT_CYAN")
        assert hasattr(AnsiColor, "LIGHT_GRAY")

    def test_text_styles_exist(self):
        """Text style codes should be defined."""
        assert hasattr(AnsiColor, "BOLD")
        assert hasattr(AnsiColor, "FAINT")
        assert hasattr(AnsiColor, "ITALIC")
        assert hasattr(AnsiColor, "UNDERLINE")
        assert hasattr(AnsiColor, "BLINK")
        assert hasattr(AnsiColor, "NEGATIVE")
        assert hasattr(AnsiColor, "CROSSED")

    def test_color_format(self):
        """Colors should follow ANSI escape code format."""
        for color in AnsiColor:
            assert color.value.startswith("\033["), f"{color.name} doesn't start with escape"
            assert color.value.endswith("m"), f"{color.name} doesn't end with 'm'"

    def test_string_concatenation(self):
        """Colors should be usable in string concatenation."""
        result = f"{AnsiColor.RED}error{AnsiColor.RESET}"
        assert "\033[0;31m" in result
        assert "\033[0m" in result
        assert "error" in result
