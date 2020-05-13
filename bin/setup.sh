#!/bin/bash

echo "Installing config to $HOME"

echo " note: going to try and source files instead of overriding"
echo
echo

source functions.sh

string=$@

if [ -z "$@" ];then
  all_install
else
  set -f                      # avoid globbing (expansion of *).
  array=(${string//:/ })

  for item in ${array[*]}
  do
    eval ${item}_install
  done
fi


