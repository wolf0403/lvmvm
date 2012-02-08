#!/bin/bash

[ -f args ] && source args

[ -z "$VOL" ] && exit 0
[ -z "$VNETID" ] && exit 0

[ -z "$VIF" ] && VIF="veth-$VNETID"
[ -z "$VIP" ] && VIP="192.168.$VNETID"
[ -z "$VMARKER" ] && VMARKER="marker_$VOL"
export VIF VIP VMARKER

if ( ps axo pid,ppid,cmd | grep "PAUSE_$VMARKER" | grep -v grep ); then
  exit 1
fi

if ( /sbin/ifconfig -a | grep ${VIF} ); then
  echo "Virtual ethernet exists. Make sure no $VOL venv is running and remove by"
  echo "/sbin/ip link delete ${VIF}-0"
  exit 1
fi

MP=/mnt/${VOL}
if ! [ -x "$MP/usr/sbin/dropbear" ]; then
  echo "Dropbear SSHd not available in environment."
  exit 1
fi

CGROUPOPT=
if [ -n "$VMEM" ]; then 
  cgcreate -g memory:$VMARKER
  echo $VMEM > /sys/fs/cgroup/memory/$VMARKER/memory.limit_in_bytes
  CGROUPOPT=" -g memory:$VMARKER"
fi

CGCMD=
if [ -n "$CGROUPOPT" ]; then
  CGCMD="/usr/bin/cgexec $CGROUPOPT "
fi

unshare -un -- $CGCMD /usr/bin/env MP=/mnt/${VOL} /bin/bash -x ./pause.sh /usr/sbin/dropbear &
sleep 1

LINE=`ps axo pid,ppid,cmd | grep "PAUSE_$VMARKER" | grep -v grep`
VPID=`echo "$LINE" | awk '{print $1;}'`
VPPID=`echo "$LINE" | awk '{print $2;}'`

[ -z "$VPID" ] || [ -z "$VPPID" ] && exit 1

ip link add name "${VIF}-0" type veth peer name "${VIF}-1"
/sbin/ifconfig "${VIF}-0" "${VIP}.1"
ip link set "${VIF}-1" netns $VPPID
kill $VPID

# Allow NAT to the vent network
/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
