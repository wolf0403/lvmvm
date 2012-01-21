#!/bin/bash

[ -z "$VG" ] && VG=data

[ -z "$VOL" ] && echo "VOL undefined." && exit 1

lvcreate --snapshot /dev/$VG/bootstrap -n $VOL -l2023
