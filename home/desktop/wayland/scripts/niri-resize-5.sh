#!/usr/bin/env sh

export RESIZE_FACTORS='["20%", "40%", "60%", "80%", "100%"]'
RUN_DIR=$(dirname $0)
$RUN_DIR/n.sh
