#!/bin/bash

source args || exit 1

SRC=/dev/$VG/$BOOTSTRAP
LE=`lvdisplay $SRC | grep 'Current LE' | egrep '[[:digit:]]+' -o `

lvcreate --snapshot /dev/$VG/$BOOTSTRAP -n $VOL -l2023
