#!/usr/bin/env python3

import os


import navi.system
from navi.logging import setup_main_logging


@setup_main_logging
def main() -> None:
    fs_ptr = navi.system.get_filesystem_pointer(global_search_mode=False, find_git_root=False)
    os.chdir(str(fs_ptr.absolute()))
    navi.system.execute([os.environ["SHELL"]])


if __name__ == "__main__":
    main()
