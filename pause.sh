#!/bin/bash 

#[ -z "$V" ] && [ -n "$1" ] && V="$1"
[ -z "$VMARKER" ] && exit 0

export V="$VMARKER"

#/sbin/ifconfig -a

cat > PAUSE_$V <<EOF
#!/bin/bash

while true; do
  sleep 10000
done

EOF

#echo $$

chmod +x PAUSE_$V
./PAUSE_$V &
wait %1
rm PAUSE_$V

#/sbin/ifconfig -a
/sbin/ifconfig "${VIF}-1" "${VIP}.2"

chroot $MP mount none /dev/pts -t devpts

exec chroot $MP $@
