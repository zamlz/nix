#!/usr/bin/env sh

export RESIZE_FACTORS='["33.333%", "66.667%", "100%"]'
RUN_DIR=$(dirname $0)
$RUN_DIR/niri-cycle-n.sh
