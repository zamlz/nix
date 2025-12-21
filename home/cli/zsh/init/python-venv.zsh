#!/bin/zsh

# Adapted to work with NixOS

# Try using pipenv as much as possible instead of these o_O

export PYTHON_VENVS_DIR="${HOME}/.local/share/python-venvs"
if [ -d "${PYTHON_VENVS_DIR}" ]; then
    mkdir -p "${PYTHON_VENVS_DIR}"
fi

# There may be a better solution to this, but I just like using the built in
# venv that is part of python3. But its a pain to write out every command
# so this does a lot of things.

venv() {
    if [[ -n "${@}" ]]; then
        vname=${1};
        pypkg=${2:-python3}
        vdir="${PYTHON_VENVS_DIR}/${vname}"

        if [ ! -d "$vdir" ]; then
            echo "Create a new virtual environment named '${vname}' ?";
            echo 'Press any key to continue or Ctrl+C to exit...\n'
            read -k1 -rs  # note this is zsh read
            echo "Creating new venv: ${vname}";
            echo "Using python package: ${pypkg}"
            nix-shell -p ${pypkg} --command "python -m venv ${vdir} --copies" \
                || return 1
        fi

        echo "Starting venv: ${vname}"
        source "${vdir}/bin/activate"
        save_window_info
    else
        echo "Python Virtual Environments (venvs)"
        tree -C -L 1 -d --noreport ${PYTHON_VENVS_DIR}/ | tail -n +2
    fi
}
