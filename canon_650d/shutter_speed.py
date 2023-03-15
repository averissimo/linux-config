#!/bin/python3

import subprocess
import re
import sys

def read_shutter():
  completed = subprocess.run(
    ["gphoto2", "-q", "--get-config", "shutterspeed"],
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT,
    text=True
  )
  regex = "([0-9]+/?[0-9]+?|bulb|[0-9]+|[0-9]+[.][0-9]+)"
  current_arr = re.findall(f"Current: {regex}\n", completed.stdout)

  values = re.findall(f"Choice: [0-9]+ {regex}\n", completed.stdout)

  if len(current_arr) > 0:
    current = current_arr[0]
  else:
    print("No current shutterspeed was found, exiting...")
    exit()

  print(f"INFO :: Current shutterspeed: {current} s per frame")
  ix = values.index(current)

  return values, ix, current

def set_shutter(val):
    cmd = ["gphoto2", "-q", f"--set-config-index", f"shutterspeed={val}"]
    result = subprocess.run(
      cmd,
      stdout=subprocess.PIPE,
      stderr=subprocess.STDOUT,
      text=True
    )
    print(result.stdout)

values, current_ix, current = read_shutter()
if len(sys.argv) <= 1:
    # print(f"Current ix: {current_ix}")
    print(f"   1 :: faster: {values[current_ix + 1]}")
    print(f"  -1 :: slower: {values[current_ix - 1]}")
elif sys.argv[1] == "1":
    print(f"     :: Setting {values[current_ix + 1]} :: faster shutterspeed (less light)")
    set_shutter(current_ix + 1)
elif sys.argv[1] == "-1":
    print(f"     :: Setting {values[current_ix + 1]} :: faster shutterspeed (less light)")
    set_shutter(current_ix - 1)
else:
    print("Error on argument, can be:")
    print("  (nothing/empty) :: get current shutter speed")
    print("   1              :: Faster shutter speed (less light)")
    print("  -1              :: Slower shutter speed (more light)")
