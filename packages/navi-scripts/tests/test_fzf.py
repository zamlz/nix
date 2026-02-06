"""Tests for navi.shell.fzf module."""

from navi.shell.fzf import Fzf


class TestFzfConstruction:
    """Tests for Fzf class initialization and argument construction."""

    def test_default_args(self):
        """Default Fzf should have ansi, reverse, and multi flags."""
        fzf = Fzf()
        assert "--ansi" in fzf.args
        assert "--reverse" in fzf.args
        assert "--multi" in fzf.args

    def test_disabled_flag(self):
        """disabled=True should add --disabled flag."""
        fzf = Fzf(disabled=True)
        assert "--disabled" in fzf.args

    def test_print_query_flag(self):
        """print_query=True should add --print-query flag."""
        fzf = Fzf(print_query=True)
        assert "--print-query" in fzf.args

    def test_no_ansi(self):
        """ansi=False should not add --ansi flag."""
        fzf = Fzf(ansi=False)
        assert "--ansi" not in fzf.args

    def test_no_reverse(self):
        """reverse=False should not add --reverse flag."""
        fzf = Fzf(reverse=False)
        assert "--reverse" not in fzf.args

    def test_no_multi(self):
        """multi=False should not add --multi flag."""
        fzf = Fzf(multi=False)
        assert "--multi" not in fzf.args

    def test_prompt_option(self):
        """prompt should be added with correct format."""
        fzf = Fzf(prompt="Select: ")
        assert "--prompt 'Select: '" in fzf.args

    def test_header_option(self):
        """header should be added with correct format."""
        fzf = Fzf(header="Choose an item")
        assert "--header 'Choose an item'" in fzf.args

    def test_header_lines_option(self):
        """header_lines should be added with correct format."""
        fzf = Fzf(header_lines=2)
        assert "--header-lines '2'" in fzf.args

    def test_delimiter_option(self):
        """delimiter should be added with correct format."""
        fzf = Fzf(delimiter=":")
        assert "--delimiter ':'" in fzf.args

    def test_preview_option(self):
        """preview should be added with correct format."""
        fzf = Fzf(preview="cat {}")
        assert "--preview 'cat {}'" in fzf.args

    def test_preview_window_option(self):
        """preview_window should be added with correct format."""
        fzf = Fzf(preview_window="right,50%")
        assert "--preview-window=right,50%" in fzf.args

    def test_preview_label_option(self):
        """preview_label should be added with correct format."""
        fzf = Fzf(preview_label="[Preview]")
        assert "--preview-label='[Preview]'" in fzf.args

    def test_nth_option(self):
        """nth should be added with correct format."""
        fzf = Fzf(nth=2)
        assert "--nth 2" in fzf.args

    def test_binds(self):
        """binds should be added as multiple --bind options."""
        fzf = Fzf(binds=["enter:accept", "ctrl-c:abort"])
        assert "--bind 'enter:accept'" in fzf.args
        assert "--bind 'ctrl-c:abort'" in fzf.args

    def test_multiple_options(self):
        """Multiple options should be combined correctly."""
        fzf = Fzf(
            prompt="Test: ",
            header="Header",
            preview="bat {}",
            binds=["enter:accept"]
        )
        assert "--prompt 'Test: '" in fzf.args
        assert "--header 'Header'" in fzf.args
        assert "--preview 'bat {}'" in fzf.args
        assert "--bind 'enter:accept'" in fzf.args
