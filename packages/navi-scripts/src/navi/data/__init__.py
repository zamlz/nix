"""Package data module for shell scripts used by navi CLI tools."""

import importlib.resources


def get_data_script_path(script_name: str) -> str:
    """Get the path to a shell script in the data directory.

    Args:
        script_name: Name of the script file (e.g., "file_preview.sh")

    Returns:
        Absolute path to the script as a string
    """
    with importlib.resources.as_file(
        importlib.resources.files("navi.data").joinpath(script_name)
    ) as path:
        # We need to return the path as a string, and it must be absolute
        # The context manager ensures the file is accessible
        return str(path.resolve())
