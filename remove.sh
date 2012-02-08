#!/bin/bash

source args || exit 1

DEV=/dev/$VG/$VOL
MP=/mnt/$VOL

function rmdev {
  if ( mount | grep $MP ); then
    echo "$MP is still mounted, can't remove."
    return 1
  fi
  if ! ( lvremove -tf $DEV ); then
    echo "Removing $DEV failed."
    return 1
  fi
  sleep 3
  lvremove -f $DEV
}

function rmcgroup {
  [ -n "$VMARKER" ] && cgdelete memory:$VMARKER
}

#VNET=`/sbin/ifconfig -a | grep -A1 veth-$VOL-host | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }'`

rmdev || exit 1
rmcgroup

# does not handle ./host.sh created veths 
if ( /sbin/ifconfig -a | grep veth-$VOL-host ); then
  /sbin/ip link delete veth-$VOL-host
  #/sbin/route delete -net $VNET.0 gw $VNET.1
fi

# host.sh created veth
if [ -n "$V" ] && ( /sbin/ifconfig -a | grep veth-$V-0 ); then
  ip link delete veth-$V-0
fi
