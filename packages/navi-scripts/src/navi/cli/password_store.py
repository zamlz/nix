#!/usr/bin/env python3

# FIXME: GPG doesn't work when using this script though sxhkd
# works just fine as a standalone?

import argparse
import os
import subprocess
from pathlib import Path
from tempfile import NamedTemporaryFile

from loguru import logger

import navi.system
from navi.logging import setup_main_logging
from navi.shell.fzf import Fzf
from navi.xorg.window import set_window_title


def get_gpg_tty_environ() -> dict[str, str]:
    gpg_tty_environ = dict(os.environ)
    result = subprocess.run(["tty"], capture_output=True)
    result.check_returncode()
    # This is necessary so that GPG uses this terminal for pinentry
    gpg_tty_environ['GPG_TTY'] = str(result.stdout, encoding="utf-8")
    return gpg_tty_environ


def get_password_data(
        password_entry: str,
        gpg_tty_environ: dict[str, str]
) -> list[str]:
    result = subprocess.run(
        ["pass", password_entry],
        capture_output=True,
        env=gpg_tty_environ
    )
    result.check_returncode()
    return str(result.stdout, encoding="utf-8").split()


@setup_main_logging
def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("-q", "--qrcode", action="store_true")
    args = parser.parse_args()

    set_window_title("FZF: Password Store")
    extra_prompt = " [QrCode]" if args.qrcode else ""
    password_store_dir = Path(os.environ['PASSWORD_STORE_DIR'])
    dir_items = navi.system.get_dir_items(
        root_dir=password_store_dir,
        mode=navi.system.SearchMode.FILE,
        show_hidden=False,
        extension="gpg"
    )
    # remove the "./" from the beginning and ".gpg" from the end
    passwords = [str(item)[:-4] for item in dir_items]
    gpg_tty_environ = get_gpg_tty_environ()

    fzf = Fzf(
        prompt=f"Password Store{extra_prompt}: ",
        header="(alt+w:open-url alt+u:get-username alt+e:edit-password)",
        binds=[
            "alt-w:become(echo get-url {1})",
            "alt-u:become(echo get-username {1})",
            "alt-e:become(echo edit {1})"
        ],
    )
    selection = fzf.prompt(passwords)
    if selection == [""]:
        return

    if len(selection[0].split()) == 2:
        possible_action, password_entry = selection[0].split()
        password_data = get_password_data(password_entry, gpg_tty_environ)
        match possible_action:
            case "edit":
                logger.info(f"Editing password {password_entry}")
                navi.system.execute(
                    f"pass edit {password_entry}".split(),
                    environ=gpg_tty_environ
                )
            case "get-username":
                logger.info(f"Getting username for {password_entry}")
                raise NotImplementedError(
                    f'Unable to get username for {password_entry}'
                )
            case "get-url":
                logger.info(f"Getting login url for {password_entry}")
                raise NotImplementedError(
                    f'Unable to get login url for {password_entry}'
                )
            case _:
                logger.error(f"Invalid action provided: {possible_action}")
                raise ValueError

    password_entry = selection[0]
    password_data = get_password_data(password_entry, gpg_tty_environ)

    if not args.qrcode:
        logger.info(f"Copying {password_entry} to clipboard")
        with NamedTemporaryFile() as ntf:
            with open(ntf.name, 'w') as f:
                f.write(password_data[0])
            navi.system.nohup(f"xclip -selection clipboard {ntf.name}".split())
            return
    else:
        logger.info(f"Creating QR code for {password_entry}")
        with NamedTemporaryFile() as ntf:
            with open(ntf.name, 'w') as f:
                f.write(password_data[0])
            subprocess.run(
                f"qrencode -r {ntf.name} --size 14 -o {ntf.name}".split()
            )
            subprocess.run(
                f"magick {ntf.name} -negate {ntf.name}".split()
            )
            with open(ntf.name, 'rb') as f:
                qrcode_image_data= f.read()
        # FIXME: It would be great to nohup this, but have to passthrough
        # the image data
        subprocess.run(
            f"feh -x --title feh:pass:{password_entry}".split() +
            "-g +200+200 -".split(),
            input=qrcode_image_data
        )


if __name__ == "__main__":
    main()
