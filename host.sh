#!/bin/bash

[ -f args ] && source args

[ -z "$VOL" ] && exit 0
[ -z "$VNETID" ] && exit 0

[ -z "$VIF" ] && VIF="veth-$VNETID"
[ -z "$VIP" ] && VIP="192.168.$VNETID"
export VMARKER="_marker_$VNETID"
export VIF VIP

if ( ps axo pid,ppid,cmd | grep $VMARKER | grep -v grep ); then
  exit 1
fi

if ( /sbin/ifconfig -a | grep ${VIF} ); then
  exit 1
fi

unshare -un -- /usr/bin/env MP=/mnt/${VOL} /bin/bash -x ./pause.sh /usr/sbin/dropbear &
sleep 1

LINE=`ps axo pid,ppid,cmd | grep "$VMARKER" | grep -v grep`
VPID=`echo "$LINE" | awk '{print $1;}'`
VPPID=`echo "$LINE" | awk '{print $2;}'`

[ -z "$VPID" ] || [ -z "$VPPID" ] && exit 1

ip link add name "${VIF}-0" type veth peer name "${VIF}-1"
/sbin/ifconfig "${VIF}-0" "${VIP}.1"
ip link set "${VIF}-1" netns $VPPID
kill $VPID

