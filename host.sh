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
  exit 1
fi

cgcreate -g memory:$VMARKER

unshare -un -- /usr/bin/cgexec -g memory:$VMARKER /usr/bin/env MP=/mnt/${VOL} /bin/bash -x ./pause.sh /usr/sbin/dropbear &
sleep 1

LINE=`ps axo pid,ppid,cmd | grep "PAUSE_$VMARKER" | grep -v grep`
VPID=`echo "$LINE" | awk '{print $1;}'`
VPPID=`echo "$LINE" | awk '{print $2;}'`

[ -z "$VPID" ] || [ -z "$VPPID" ] && exit 1

ip link add name "${VIF}-0" type veth peer name "${VIF}-1"
/sbin/ifconfig "${VIF}-0" "${VIP}.1"
ip link set "${VIF}-1" netns $VPPID
kill $VPID

