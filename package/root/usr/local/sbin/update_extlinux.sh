#!/bin/bash

TIMEOUT=""
DEFAULT=""
APPEND="rw"
APPEND="$APPEND panic=10"
APPEND="$APPEND init=/sbin/init"
APPEND="$APPEND coherent_pool=1M"
APPEND="$APPEND ethaddr=\${ethaddr} eth1addr=\${eth1addr} serial=\${serial#}"
APPEND="$APPEND cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1"

set -eo pipefail

. /etc/default/extlinux

echo "Creating new extlinux.conf..." 1>&2

mkdir -p /boot/extlinux/
exec 1> /boot/extlinux/extlinux.conf.new

echo "timeout ${TIMEOUT:-10}"
echo "menu title select kernel"
[[ -n "$DEFAULT" ]] && echo "default $DEFAULT"
echo ""

linux-version list | while read VERSION; do
  echo "label kernel-$VERSION"
  echo "    kernel /boot/vmlinuz-$VERSION"
  if [[ -f "/boot/initrd.img-$VERSION" ]]; then
    echo "    initrd /boot/initrd.img-$VERSION"
  fi
  if [[ -f "/boot/dtb-$VERSION" ]]; then
    echo "    fdt /boot/dtb-$VERSION"
  elif [[ -d "/boot/dtbs/$VERSION" ]]; then
    echo "    devicetreedir /boot/dtbs/$VERSION"
  elif [[ -d "/usr/lib/linux-image-$VERSION" ]]; then
    echo "    devicetreedir /usr/lib/linux-image-$VERSION"
  else
    echo "Missing dtb for $VERSION" 1>&2
    exit 1
  fi
  echo "    append $APPEND"
  echo ""
done

exec 1<&-

echo "Installing new extlinux.conf..." 1>&2
mv /boot/extlinux/extlinux.conf.new /boot/extlinux/extlinux.conf
