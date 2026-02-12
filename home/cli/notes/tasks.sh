#!/bin/sh
cd ${NOTES_DIRECTORY}
rg \
  --color=always \
  --column \
  --line-number \
  --no-heading \
  --smart-case \
  --type=md \
  -- '^\s*- \[ \]' \
