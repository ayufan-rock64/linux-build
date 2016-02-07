#!/bin/sh
#
# Simple script to create a small busybox based initrd. It requires a compiled
# busybox static binary. You can also use any other initrd for example one
# from Debian like # https://d-i.debian.org/daily-images/arm64/20160206-00:06/netboot/debian-installer/arm64/
#

set -e

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
/bin/busybox --install -s
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
exec /bin/sh
EOF
chmod 755 $TEMP/init

find . | cpio -H newc -o > $TEMPFILE

cd -

cat $TEMPFILE | gzip >initrd.gz

rm $TEMPFILE
rm -rf $TEMP
sync
