#!/bin/bash

source args || exit 1

DEV=/dev/$VG/$VOL

function rmdev {
lvremove -tf $DEV || return 1
sleep 1
lvremove -f $DEV
}

#VNET=`/sbin/ifconfig -a | grep -A1 veth-$VOL-host | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }'`

rmdev

# does not handle ./host.sh created veths 
if ( /sbin/ifconfig -a | grep veth-$VOL-host ); then
  /sbin/ip link delete veth-$VOL-host
  #/sbin/route delete -net $VNET.0 gw $VNET.1
fi

# host.sh created veth
if [ -n "$V" ] && ( /sbin/ifconfig -a | grep veth-$V-0 ); then
  ip link delete veth-$V-0
fi
