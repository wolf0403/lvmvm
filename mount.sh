#!/bin/bash

[ -z "$VG" ] && VG=data

[ -z "$VOL" ] && echo "VOL not defined." && exit 1
DEV="`readlink /dev/$VG/$VOL`"

if [ ! -b "$DEV" ]; then
  if [ ! -b "/dev/$VG/$DEV" ]; then
    echo "/dev/$VG/$VOL link to $DEV is not a block device."
    exit 1
  fi
fi

if [ `id -u` -ne 0 ]; then 
  echo "Run as root required."
  exit 1
fi

MP="/mnt/$VOL"

[ ! -d $MP ] && mkdir "$MP"
[ ! -d $MP ] && echo "$MP creation failed." && exit 1

mount /dev/$VG/$VOL "$MP"
mount /proc "$MP/proc" --bind
mount /sys "$MP/sys" --bind
mount /dev "$MP/dev" --bind
echo $VOL > $MP/etc/hostname
touch $MP/chroot.$VOL

[ -x chroot/$VOL.mount ] && chroot/$VOL.mount
