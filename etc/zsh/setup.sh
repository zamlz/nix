#!/bin/sh

# GnuPG Setup Script
# ------------------

. $HOME/lib/shell/logging && eval "$(get_logger etc.zsh.setup)"

logger "Setting up Z Shell"

CONFIG_SOURCE=$HOME/etc/zsh
CONFIG_TARGET=$HOME

if [ ! -d "$CONFIG_TARGET" ]; then
    logger "Making directory $CONFIG_TARGET"
    mkdir $CONFIG_TARGET
fi

logger "Creating symlink for ~/.zshrc"
ln -s $CONFIG_SOURCE/rc $CONFIG_TARGET/.zshrc

logger "Creating symlink for ~/.zlogin"
ln -s $CONFIG_SOURCE/login $CONFIG_TARGET/.zlogin