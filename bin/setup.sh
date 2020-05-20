#!/bin/bash

BASE_DIR=$(readlink -f $(dirname $0)/..)
echo "Installing config to $HOME"

echo " note: going to try and source files instead of overriding"
echo
echo

source $BASE_DIR/functions.sh

string=$@

if [ -z "$@" ];then
  all_install | sed -E 's/^(.)/    \1/g'
else
  #set -f                      # avoid globbing (expansion of *).
  array=(${string//:/ })

  for item in ${array[*]}
  do
    eval "${item}_install"
  done
fi
