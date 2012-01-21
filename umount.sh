#!/bin/bash

[ -z "$VG" ] && VG=data

if [ -z "$VOL" ] || ! ( mount | grep "/mnt/$VOL" ) ; then 
  echo "Mount /mnt/$VOL does not exist."
  exit 1
fi

[ -x chroot/$VOL.umount ] && chroot/$VOL.umount

umount /mnt/$VOL/proc
umount /mnt/$VOL/sys
umount /mnt/$VOL/dev
umount /mnt/$VOL

