#!/bin/sh

man_args=$(echo $@ \
    | tr -d '()' \
    | awk '{printf "%s ", $2} {print $1}')
echo $man_args
man $man_args
