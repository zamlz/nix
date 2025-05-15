#!/bin/sh

set -e

HOOK_PATH=".git/hooks/"

echo "Installing prepare-commit-msg hook..."
cp hooks/prepare-commit-msg "$HOOK_PATH"
chmod +x "$HOOK_PATH/prepare-commit-msg"
echo "Hook installed at $HOOK_PATH"
