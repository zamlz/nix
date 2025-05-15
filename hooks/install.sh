#!/bin/sh
set -e

HOOK_PATH=".git/hooks/prepare-commit-msg"

echo "Installing prepare-commit-msg hook..."
cp hooks/prepare-commit-msg.sh "$HOOK_PATH"
chmod +x "$HOOK_PATH"
echo "Hook installed at $HOOK_PATH"
