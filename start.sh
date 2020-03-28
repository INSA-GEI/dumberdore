#!/usr/bin/env bash
# getwindidbypid
# 
# Get the ID of a window by PID (if the process has a window).
# 
# Usage:
#   getwindidbypid <PID>
# 

./dumberdore.x86_64 & export DUMBER_PID=$!
echo "dumby launched"
cpulimit --pid ${DUMBER_PID} -l 50 &

sleep 1
echo ${DUMBER_PID}
while IFS= read line; do
  if [[ "${line}" =~ (0x)([0-9a-z]+)([ ][- ][0-9]+[ ])([0-9]*) ]]; then
    winId="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
    pid="${BASH_REMATCH[4]}"
    if [[ "${pid}" -eq "${DUMBER_PID}" ]]; then
      WIND_IDS+=("${winId}")
    fi
  fi
done < <(wmctrl -lp)

if [ "${#WIND_IDS[@]}" -gt 0 ]; then
  echo "xid is ${WIND_IDS[0]}"
fi

gst-launch-1.0 -v ximagesrc xid=${WIND_IDS[0]} ! videoconvert ! videoscale ! video/x-raw,format=UYVY,width=640,height=480,framerate=30/1 ! identity drop-allocation=1 ! v4l2sink device=/dev/video0



