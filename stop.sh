#!/bin/bash

[ -f args ] && source args

LINE=`ps axo pid,cmd | grep "sleep" | grep -v grep`
PID=`echo "$LINE" | awk '{print $1;}'`

for p in $PID; do 
  if [ `readlink /proc/$p/root` == "/mnt/$VOL" ]; then
    kill $p
  fi
done

/sbin/ip link delete veth-$VNETID-0
