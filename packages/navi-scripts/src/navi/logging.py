import sys
from functools import wraps
from pathlib import Path
from typing import Callable, TypeVar

from loguru import logger


LOG_DIR = Path.home() / ".local/share/navi"
LOG_FILE = LOG_DIR / "navi_system.log"

F = TypeVar("F", bound=Callable[..., None])


def setup_main_logging(func: F) -> F:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    logger.remove()
    logger.add(LOG_FILE, rotation="10 MB", level="DEBUG")
    logger.add(sys.stderr, level="INFO")

    @wraps(func)
    def wrapped_func(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as e:
            logger.exception(f"Exception encountered: {e}")
            input()
            sys.exit(1)

    return wrapped_func  # type: ignore[return-value]
