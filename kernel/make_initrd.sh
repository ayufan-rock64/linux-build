#!/bin/sh
#
# Simple script to create a small busybox based initrd. It requires a compiled
# busybox static binary. You can also use any other initrd for example one
# from Debian like # https://d-i.debian.org/daily-images/arm64/20160206-00:06/netboot/debian-installer/arm64/
#
# Run this script with fakeroot or as root.

set -e

if [ "$(id -u)" -ne "0" ]; then
	exec fakeroot $0 $@
fi

BUSYBOX="../busybox"

TEMP=$(mktemp -d)
TEMPFILE=$(mktemp)

mkdir -p $TEMP/bin
cp -va $BUSYBOX/busybox $TEMP/bin

cd $TEMP
mkdir dev proc sys tmp sbin
mknod dev/console c 5 1
cat > $TEMP/init <<EOF
#!/bin/busybox sh

# Install busybox
/bin/busybox --install -s

# Mount the /proc and /sys filesystems.
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

sleep 1

if [ -e /dev/mmcblk0p2 ]; then
	# Mount real root.
	mkdir -p /mnt/root
	mount -o rw /dev/mmcblk0p2 /mnt/root

	if [ -e /mnt/root/init ]; then
		# Cleanup.
		umount /proc
		umount /sys
		umount /dev

		# Boot the real system.
		exec switch_root /mnt/root /sbin/init
	fi

fi

echo "Dropping to a shell."
echo
setsid cttyhack /bin/sh
EOF
chmod 755 $TEMP/init

find . | cpio -H newc -o > $TEMPFILE

cd -

cat $TEMPFILE | gzip >initrd.gz

rm $TEMPFILE
rm -rf $TEMP
sync
