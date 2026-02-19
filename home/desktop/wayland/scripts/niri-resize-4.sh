#!/usr/bin/env sh

export RESIZE_FACTORS='["25%", "50%", "75%", "100%"]'
RUN_DIR=$(dirname $0)
$RUN_DIR/n.sh
