#!/usr/bin/python3

import asyncio
import subprocess
import re
import sys
import time
import logging

logging.basicConfig(format='%(asctime)s :: %(message)s', datefmt='%H:%M:%S', level=logging.INFO)

SLEEP_INTERVAL = 60
OPEN_CAMERA_MINUTES = 5

async def main():
    logging.info("Starting liveview for Canon 650D\n")

    count = 0

    while True:
        logging.info("Killing all processes named gphoto...")
        kill_process_callback()
        if count == 0:
            camera_operations(1)
        count = (count + 1) % OPEN_CAMERA_MINUTES
        print("-------------------------------------")
        await asyncio.sleep(SLEEP_INTERVAL)  # wait to see timer works

#
#
#
#

def kill_process_callback_internal():
    # await asyncio.sleep(0.1)
    ps = subprocess.Popen(
        ["ps", "-aux"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True
    )

    aa = subprocess.Popen(("grep", "gphoto"), stdin=ps.stdout, stdout=subprocess.PIPE)

    try:
        bb = subprocess.Popen(("grep", "-v",  "grep"), stdin=aa.stdout, stdout=subprocess.PIPE)

    except Exc:
        print("No gphoto process going on")#
        ps.wait()
        return False

    try:
        cc = subprocess.check_output(("awk", "{ print $2 }"), stdin=bb.stdout)
    except:
        print("Problem with awk")
        ps.wait()
        return False
    ps.wait()

    cc = cc.decode("ascii")
    cc = re.sub("\n$", "", cc)

    if cc == "":
        return False

    arr_proc = cc.split("\n")

    logging.info(f"  -> Killing {len(arr_proc)} processes")

    for el in arr_proc:
        if el == "":
            continue
        try:
            subprocess.run(["kill", "-9", f"{el}"])
        except:
            print(f"Couldn't kill {el}")

    return True

def kill_process_callback():
    count = 0
    while kill_process_callback_internal() or count == 10:
        logging.info("  -> Found processes to kill, will try again just in case")
        count += 1

def camera_operations(operation):
    kill_process_callback()
    subprocess.run(["gphoto2", "--set-config", f"eosmoviemode={operation}"])
    if operation == 1:
        logging.info("Opening camera")
    else:
        logging.info("Closing camera")
    time.sleep(1)
    kill_process_callback()
    if operation == 1:
        logging.info("Reseting autofocusdrive")
        subprocess.run(["gphoto2", "--set-config", "/main/actions/autofocusdrive=0"])

if len(sys.argv) > 1:
    valid_args = {"0": "Close", "1": "Open"}
    operation = sys.argv[1]
    if not (operation in valid_args):
        logging.error(f"Error: '{operation}' is not a valid argument (0 to close or 1 to open)")
    else:
        camera_operations(operation)
else:
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    try:
        loop.run_until_complete(main())
    except KeyboardInterrupt:
        print('\nYou pressed ctrl+c, terminating in 2 seconds...')
    finally:
        loop.run_until_complete(loop.shutdown_asyncgens())
        loop.close()
        time.sleep(2)
        kill_process_callback()
        camera_operations(0)
