#!/usr/bin/env sh

export RESIZE_FACTORS='["50%", "100%"]'
RUN_DIR=$(dirname $0)
$RUN_DIR/niri-cycle-n.sh
