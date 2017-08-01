#!/bin/bash
#
# Simple script to create a rootfs for aarch64 platforms including support
# for Kernel modules created by the rest of the scripting found in this
# module.
#
# Use this script to populate the second partition of disk images created with
# the simpleimage script of this project.
#

set -e

BUILD="../build"
DEST="$1"
DISTRO="$2"
VARIANT="$3"
BUILD_ARCH="$4"
MODEL="$5"
shift 5

export LC_ALL=C

if [ -z "$MODEL" ]; then
	echo "Usage: $0 <destination-folder> <distro> <variant: mate, i3 or minimal> <arch> <model> <packages...>"
	exit 1
fi

if [ "$(id -u)" -ne "0" ]; then
	echo "This script requires root."
	exit 1
fi

DEST=$(readlink -f "$DEST")
if [ -n "$LINUX" -a "$LINUX" != "-" ]; then
	LINUX=$(readlink -f "$LINUX")
fi

if [ ! -d "$DEST" ]; then
	echo "Destination $DEST not found or not a directory."
	exit 1
fi

if [ "$(ls -A -Ilost+found -Iboot $DEST)" ]; then
	echo "Destination $DEST is not empty. Aborting."
	exit 1
fi

if [ -z "$DISTRO" ]; then
	DISTRO="xenial"
fi

if [ -n "$BOOT" ]; then
	BOOT=$(readlink -f "$BOOT")
fi

TEMP=$(mktemp -d)
cleanup() {
	if [ -e "$DEST/proc/cmdline" ]; then
		umount "$DEST/proc"
	fi
	if [ -d "$DEST/sys/kernel" ]; then
		umount "$DEST/sys"
	fi
	umount "$DEST/tmp" || true
	if [ -d "$TEMP" ]; then
		rm -rf "$TEMP"
	fi
}
trap cleanup EXIT

ROOTFS=""
TAR_OPTIONS=""

case $DISTRO in
	arch)
		ROOTFS="http://archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz"
		TAR_OPTIONS="-z"
		;;
	xenial|zesty|artful)
		version=$(curl -s https://api.github.com/repos/ayufan-rock64/linux-rootfs/releases/latest | jq -r ".tag_name")
		ROOTFS="https://github.com/ayufan-rock64/linux-rootfs/releases/download/${version}/ubuntu-${DISTRO}-${VARIANT}-${version}-${BUILD_ARCH}.tar.xz"
		TAR_OPTIONS="-J --strip-components=1 binary"
		;;
	sid|jessie|stretch)
		version=$(curl -s https://api.github.com/repos/ayufan-rock64/linux-rootfs/releases/latest | jq -r ".tag_name")
		ROOTFS="https://github.com/ayufan-rock64/linux-rootfs/releases/download/${version}/debian-${DISTRO}-${VARIANT}-${version}-${BUILD_ARCH}.tar.xz"
		TAR_OPTIONS="-J --strip-components=1 binary"
		;;
	*)
		echo "Unknown distribution: $DISTRO"
		exit 1
		;;
esac

mkdir -p $BUILD
TARBALL="$TEMP/$(basename $ROOTFS)"

mkdir -p "$BUILD"
if [ ! -e "$TARBALL" ]; then
	echo "Downloading $DISTRO rootfs tarball ..."
	wget -O "$TARBALL" "$ROOTFS"
fi

# Extract with BSD tar
echo -n "Extracting ... "
set -x
tar -xf "$TARBALL" -C "$DEST" $TAR_OPTIONS
echo "OK"
rm -f "$TARBALL"

# Add qemu emulation.
cp /usr/bin/qemu-aarch64-static "$DEST/usr/bin"
cp /usr/bin/qemu-arm-static "$DEST/usr/bin"

# Prevent services from starting
cat > "$DEST/usr/sbin/policy-rc.d" <<EOF
#!/bin/sh
exit 101
EOF
chmod a+x "$DEST/usr/sbin/policy-rc.d"

do_chroot() {
	cmd="$@"
	mount -o bind /tmp "$DEST/tmp"
	chroot "$DEST" mount -t proc proc /proc
	chroot "$DEST" mount -t sysfs sys /sys
	chroot "$DEST" $cmd
	chroot "$DEST" umount /sys
	chroot "$DEST" umount /proc
	umount "$DEST/tmp"
}

do_install() {
	FILE=$(basename "$1")
	cp "$1" "$DEST/$(basename "$1")"
	do_chroot dpkg -i "$FILE" || do_chroot bash
	do_chroot rm "$FILE"
}

# Run stuff in new system.
case $DISTRO in
	arch)
		echo "No longer supported"
		exit 1
		;;
	xenial|sid|jessie|stretch)
		rm "$DEST/etc/resolv.conf"
		cp /etc/resolv.conf "$DEST/etc/resolv.conf"
		case "$VARIANT" in
			openmediavault)
				DEBUSER=root
				DEBUSERPW=openmediavault
				;;

			*)
				DEBUSER=rock64
				DEBUSERPW=rock64
				;;
		esac
		EXTRA_ARCHS="arm64"
		cat <<EOF | do_chroot bash
#!/bin/sh
set -ex
export DEBIAN_FRONTEND=noninteractive
locale-gen en_US.UTF-8
# add non-free
sed -i 's/main contrib$/main contrib non-free/g' /etc/apt/sources.list
apt-get -y update
apt-get -y install dosfstools curl xz-utils iw rfkill wpasupplicant openssh-server alsa-utils \
	nano git build-essential vim jq wget ca-certificates software-properties-common dirmngr \
	gdisk parted figlet htop fake-hwclock usbutils sysstat fping iperf3 iozone3 ntp
fake-hwclock save
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BF428671
if [[ "$DISTRO" == "jessie" ]]; then
	REPO=xenial
elif [[ "$DISTRO" == "stretch" ]]; then
	REPO=xenial
else
	REPO="$DISTRO"
fi
if [[ "$DISTRO" == "xenial" || "$DISTRO" == "zesty" || "$DISTRO" == "artful" ]]; then
	apt-get -y install landscape-common
fi
add-apt-repository "deb http://ppa.launchpad.net/ayufan/rock64-ppa/ubuntu \$REPO main"
curl -fsSL http://deb.ayufan.eu/orgs/ayufan-rock64/archive.key | apt-key add -
apt-get update -y
apt-get dist-upgrade -y
apt-get install -y flash-kernel u-boot-tools
if [[ "$DEBUSER" != "root" ]]; then
	adduser --gecos $DEBUSER --disabled-login $DEBUSER --uid 1000
	chown -R 1000:1000 /home/$DEBUSER
	usermod -a -G sudo,audio,adm,input,video,plugdev,ssh $DEBUSER
	chage -d 0 "$DEBUSER"
fi
echo "$DEBUSER:$DEBUSERPW" | chpasswd
apt-get clean
EOF
		echo -n UTC > "$DEST/etc/timezone"
		echo "Rockchip RK3328 Rock64" > "$DEST/etc/flash-kernel/machine"
		cat > "$DEST/etc/apt/sources.list.d/ayufan-rock64.list" <<EOF
deb http://deb.ayufan.eu/orgs/ayufan-rock64/releases /

# uncomment to use pre-release kernels and compatibility packages
# deb http://deb.ayufan.eu/orgs/ayufan-rock64/pre-releases /
EOF
		cat > "$DEST/etc/hostname" <<EOF
$MODEL
EOF
		cat > "$DEST/etc/fstab" <<EOF
LABEL=boot /boot/efi vfat defaults 0 0
EOF
		cat > "$DEST/etc/hosts" <<EOF
127.0.0.1 localhost
127.0.1.1 $MODEL

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
		cat >> "$DEST/etc/securetty" <<EOF
# Rock 64
ttyFIQ0
EOF
		for arch in $EXTRA_ARCHS; do
			if [[ "$arch" != "$BUILD_ARCH" ]]; then
				do_chroot dpkg --add-architecture "$arch"
			fi
		done
		for package in "$@"; do
			do_install "$package"
		done
		case "$VARIANT" in
			mate)
				do_chroot /usr/local/sbin/install_desktop.sh mate
				do_chroot systemctl set-default graphical.target
				;;

			i3)
				do_chroot /usr/local/sbin/install_desktop.sh i3
				do_chroot systemctl set-default graphical.target
				;;

			openmediavault)
				do_chroot /usr/local/sbin/install_openmediavault.sh
				;;
		esac
		do_chroot systemctl enable ssh-keygen
		sed -i 's|After=rc.local.service|#\0|;' "$DEST/lib/systemd/system/serial-getty@.service"
		rm -f "$DEST/etc/resolv.conf"
		rm -f "$DEST"/etc/ssh/ssh_host_*
		do_chroot ln -s /run/resolvconf/resolv.conf /etc/resolv.conf
		do_chroot apt-get clean
		;;
	*)
		;;
esac

# Bring back folders
mkdir -p "$DEST/lib"
mkdir -p "$DEST/usr"

# Clean up
rm -f "$DEST/usr/bin/qemu-arm-static"
rm -f "$DEST/usr/bin/qemu-aarch64-static"
rm -f "$DEST/usr/sbin/policy-rc.d"
rm -f "$DEST/var/lib/dbus/machine-id"
rm -f "$DEST/SHA256SUMS"

echo "Done - installed rootfs to $DEST"
