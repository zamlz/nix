#!/usr/bin/env python3


from navi.logging import setup_main_logging
from navi.xorg.window import save_active_window_id


@setup_main_logging
def main() -> None:
    save_active_window_id()


if __name__ == "__main__":
    main()
