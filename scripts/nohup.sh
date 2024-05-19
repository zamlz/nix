#!/usr/bin/env sh

# This script lets you nohup any command safely. I have not found a way to
# properly nohup in python3 so I will be using this a simple way of nohup-ing
# whenever I want.
# > Look at the python3 module "navi.system.nohup"

echo "$@"
nohup "$@" > /dev/null 2>&1 &
sleep 0.1
