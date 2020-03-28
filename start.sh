#!/usr/bin/env bash
# Usage:
#   start <v4l2loopback_path>
# 

if [ "$#" -ne 1 ]; then
 echo "Add path of v4l2loopback folder as parameter"
else
 LOCAL=${PWD}

 sudo modprobe v4l2loopback
 sudo rmmod v4l2loopback
 cd ${1}
 sudo insmod v4l2loopback.ko max_buffers=2

 cd ${LOCAL}
 ./dumberdore.x86_64 & export DUMBER_PID=$!
 cpulimit --pid ${DUMBER_PID} -l 50 &
 echo "dumby launched"

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

 #v4l2loopback-ctl set-caps "video/x-raw,format=UYVY,width=640,height=480" /dev/video0
 v4l2loopback-ctl set-fps 30 /dev/video0
 gst-launch-1.0 -v ximagesrc xid=${WIND_IDS[0]} ! videoconvert ! videoscale ! video/x-raw,format=UYVY,width=640,height=480,framerate=30/1 ! identity drop-allocation=1 ! v4l2sink device=/dev/video0
fi


