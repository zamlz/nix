import sys
from functools import wraps
from pathlib import Path
from subprocess import CalledProcessError
from typing import Callable, TypeVar

from loguru import logger


LOG_DIR = Path.home() / ".local/share/navi"
LOG_FILE = LOG_DIR / "navi_system.log"

F = TypeVar("F", bound=Callable[..., None])


def _log_process_errors(e: CalledProcessError) -> None:
    logger.error(f"Command failed: \n{e.cmd}")
    logger.error(f"Command stdout: \n{e.stdout}")
    logger.error(f"Command stderr: \n{e.stderr}")


def _pause_and_exit_on_error(e: Exception) -> None:
    logger.exception(f"Exception encountered: {e}")
    input()
    sys.exit(1)


def setup_main_logging(func: F) -> F:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    logger.remove()
    logger.add(LOG_FILE, rotation="10 MB", level="DEBUG")
    logger.add(sys.stderr, level="INFO")

    @wraps(func)
    def wrapped_func(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except CalledProcessError as e:
            _log_process_errors(e)
            _pause_and_exit_on_error(e)
        except Exception as e:
            _pause_and_exit_on_error(e)

    return wrapped_func  # type: ignore[return-value]
