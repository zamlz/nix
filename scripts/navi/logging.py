import logging
import os
from logging.handlers import RotatingFileHandler 
from pathlib import Path
from typing import Any, List


LOG_DIR = Path.home() / ".local/share/navi"
LOG_FILE = LOG_DIR / "navi_system.log"


def setup_logger() -> None:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    handlers: List[logging.StreamHandler[Any]] = [
        RotatingFileHandler(LOG_FILE, maxBytes=100000, backupCount=1),
    ]
    if os.getenv("NAVI_LOG_STDOUT", "False").lower() == "true" :
        handlers.append(logging.StreamHandler())
    logging.basicConfig(
        level=logging.DEBUG,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        handlers=handlers
    )

