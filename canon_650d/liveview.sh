#!/bin/bash

cmd1="ps -aux | grep gphoto | grep -v grep | awk '{ print $2 }' | xargs kill -9 2> /dev/null"
operation="0"
cmd2_template="gphoto2 --set-config eosmoviemode="
cmd2="$cmd2_template$operation"
cmd3="gphoto2 -q --set-config /main/actions/autofocusdrive=0"


open_camera() {
  operation="1"
  cmd2="$cmd2_template$operation"
}

close_camera() {
  operation="0"
  cmd2="$cmd2_template$operation"
}

# killall gphoto processes
ps -aux | grep gphoto | grep -v grep | awk '{ print $2 }' | xargs kill -9 2> /dev/null

if [ -z $1 ]; then
  bash "$cmd1"
  open_camera
  watch -n 200 bash -c "$cmd1 ; $cmd2 && sleep 3 && $cmd3"
  close_camera
  bash -c "$cmd2"
elif [ $1 -eq 1 ]; then
  open_camera
  echo "Running $cmd2"
  bash -c "$cmd2"
  sleep 3
  bash -c "$cmd3"
else
  close_camera
  echo "Running $cmd2"
  bash -c "$cmd2"
fi
