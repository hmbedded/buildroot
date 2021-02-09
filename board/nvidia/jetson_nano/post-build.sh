#!/bin/sh

# Add a console on ttyS0
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^ttyS0::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
ttyS0::respawn:/sbin/getty -L  ttyS0 0 vt100 # Serial Port Console' ${TARGET_DIR}/etc/inittab
fi

# If there's an initrd don't mount /proc in inittab as it's done in the 
# initrd so trying to mount again results in a warning
if [ -e ${TARGET_DIR}/etc/inittab ]; then
	ret=`grep INITRD ${TARGET_DIR}/boot/extlinux/extlinux.conf -c`
	if [ $ret != 0 ]; then
		grep -qE '^#::sysinit:/bin/mount -t proc' ${TARGET_DIR}/etc/inittab || \
		sed -i 's/::sysinit:\/bin\/mount -t proc/#::sysinit:\/bin\/mount -t proc/' ${TARGET_DIR}/etc/inittab
	else
		sed -i 's/#::sysinit:\/bin\/mount -t proc/::sysinit:\/bin\/mount -t proc/' ${TARGET_DIR}/etc/inittab
	fi
fi
