#!/bin/sh

set -u
set -e

# Add a console on ttyS0
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^ttyS0::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
ttyS0::respawn:/sbin/getty -L  ttyS0 0 vt100 # Serial Port Console' ${TARGET_DIR}/etc/inittab
fi
