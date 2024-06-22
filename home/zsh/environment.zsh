# We do not need #! here. NixOS may prefix/postfix this script as needed.

# This file should contain anything we would normally put in `.zshenv`

# Make our pager a little more intelligent
export LESS="-R --no-init --quit-if-one-screen"

# no longer creates __pycache__ folders in the same folder as *.py files
export PYTHONPYCACHEPREFIX="$HOME/.cache/__pycache__"

# prepare the window id directory
WINDIR=/tmp/.wid
mkdir -p $WINDIR

# Load window info for given Target Window ID (used with pwdcfw.sh)
function load_window_info() {
    if [ -n "$DISPLAY" ] && [ -n "$TARGET_WINDOWID" ]; then
        source "$WINDIR/$TARGET_WINDOWID"
        cd $WINDOW_PWD
        unset TARGET_WINDOWID
    fi
      }

# Save window info for given Window ID (used with pwdcfw.sh)
function save_window_info() {
    if [ -n "$DISPLAY" ] && [ -n "$WINDOWID" ]; then
        WINDOWID_FILE="$WINDIR/$WINDOWID"
        echo "WINDOW_PWD='$(pwd)'" | tee $WINDOWID_FILE
    fi
      }

# Finally, just save the window info in case other processes are started without
# ever needing a zsh prompt (alacritty spawners)
save_window_info > /dev/null 2>&1
