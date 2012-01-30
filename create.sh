#!/bin/bash

source args || exit 1

SRC=/dev/$VG/$BOOTSTRAP
LE=`lvdisplay $SRC | grep 'Current LE' | egrep '[[:digit:]]+' -o `

lvcreate --snapshot /dev/$VG/$BOOTSTRAP -n $VOL -l2023

# use network code in host.sh
if [ -n "$VNET" ]; then
  /sbin/ip link add name veth-$VOL-host type veth peer name veth-$VOL-virt
  /sbin/ifconfig veth-$VOL-host $VNET.1
  /sbin/route add -net $VNET.0/24 dev veth-$VOL-host
  /bin/echo 1 > /proc/sys/net/ipv4/conf/veth-$VOL-host/proxy_arp
fi
