#!/bin/bash

source args || exit 1

if [ -z "$VOL" ] || ! ( mount | grep "/mnt/$VOL" ) ; then 
  echo "Mount /mnt/$VOL does not exist."
  exit 1
fi

export VG VOL MP="/mnt/$VOL"

if [ -d chroot ]; then
pushd chroot
[ -x ./$VOL.umount ] && ./$VOL.umount
[ -x ./umount ] && ./umount
popd
fi

umount /mnt/$VOL/proc
umount /mnt/$VOL/sys
umount /mnt/$VOL/dev/pts
umount /mnt/$VOL/dev
sleep 1
umount /mnt/$VOL || exit 1

rm -rf /mnt/$VOL


