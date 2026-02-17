#!/usr/bin/env python3

from navi.logging import setup_main_logging
from navi.window_manager import get_window_manager


@setup_main_logging
def main() -> None:
    get_window_manager().save_active_window_id()


if __name__ == "__main__":
    main()
