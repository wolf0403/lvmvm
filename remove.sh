#!/bin/bash

source args || exit 1

DEV=/dev/$VG/$VOL

lvremove -tf $DEV || exit 1
sleep 1
lvremove -f $DEV

VNET=`/sbin/ifconfig -a | grep -A1 veth-$VOL-host | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }'`

# does not handle ./host.sh created veths 
if ( /sbin/ifconfig -a | grep veth-$VOL-host ); then
  /sbin/ip link delete veth-$VOL-host
  #/sbin/route delete -net $VNET.0 gw $VNET.1
fi
