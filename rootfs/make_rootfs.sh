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
	if [[ "$DEBUG" == "shell" ]]; then
		pushd "$DEST"
		bash
		popd
	fi
	umount "$DEST/var/cache/apt" || true
	umount "$DEST/proc/mdstat" || true
	umount "$DEST/proc" || true
	umount "$DEST/sys" || true
	umount "$DEST/tmp" || true
	rm -r "$TEMP"
}
trap cleanup EXIT

ROOTFS=""
TAR_OPTIONS=""
DISTRIB=""

case $DISTRO in
	bionic|disco)
		version=$(curl -s https://api.github.com/repos/ayufan-rock64/linux-rootfs/releases/latest | jq -r ".tag_name")
		ROOTFS="https://github.com/ayufan-rock64/linux-rootfs/releases/download/${version}/ubuntu-${DISTRO}-${VARIANT}-${version}-${BUILD_ARCH}.tar.xz"
		FALLBACK_ROOTFS="https://github.com/ayufan-rock64/linux-rootfs/releases/download/${version}/ubuntu-${DISTRO}-minimal-${version}-${BUILD_ARCH}.tar.xz"
		TAR_OPTIONS="-J --strip-components=1 binary"
		DISTRIB="ubuntu"
		EXTRA_ARCHS="arm64"
		;;

	stretch|buster)
		version=$(curl -s https://api.github.com/repos/ayufan-rock64/linux-rootfs/releases/latest | jq -r ".tag_name")
		ROOTFS="https://github.com/ayufan-rock64/linux-rootfs/releases/download/${version}/debian-${DISTRO}-${VARIANT}-${version}-${BUILD_ARCH}.tar.xz"
		FALLBACK_ROOTFS="https://github.com/ayufan-rock64/linux-rootfs/releases/download/${version}/debian-${DISTRO}-minimal-${version}-${BUILD_ARCH}.tar.xz"
		TAR_OPTIONS="-J --strip-components=1 binary"
		DISTRIB="debian"
		EXTRA_ARCHS="arm64"
		;;

	*)
		echo "Unknown distribution: $DISTRO"
		exit 1
		;;
esac

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

CACHE_ROOT="${CACHE_ROOT:-tmp}"
mkdir -p "$CACHE_ROOT"
TARBALL="${CACHE_ROOT}/$(basename $ROOTFS)"

if [ ! -e "$TARBALL" ]; then
	echo "Downloading $DISTRO rootfs tarball ..."
	pushd "$CACHE_ROOT"
	if ! flock "$(basename "$ROOTFS").lock" wget -c "$ROOTFS"; then
		TARBALL="${CACHE_ROOT}/$(basename "$FALLBACK_ROOTFS")"
		echo "Downloading fallback $DISTRO rootfs tarball ..."
		flock "$(basename "$FALLBACK_ROOTFS").lock" wget -c "$FALLBACK_ROOTFS"
	fi
	popd
fi

# Extract with BSD tar
echo -n "Extracting ... "
set -ex
tar -xf "$TARBALL" -C "$DEST" $TAR_OPTIONS
echo "OK"

# Mount needed directories
mount -o bind /tmp "$DEST/tmp"
chroot "$DEST" mount -t proc proc /proc
chroot "$DEST" mount -t sysfs sys /sys
chroot "$DEST" mount --bind /dev/null /proc/mdstat

# Mount var/apt/cache
# mkdir -p "$CACHE_ROOT/apt" "$DEST/var/cache/apt"
# mount -o bind "$CACHE_ROOT/apt" "$DEST/var/cache/apt"

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
	chroot "$DEST" $CHROOT_PREFIX "$@"
}

do_install() {
	FILE=$(basename "$1")
	cp "$1" "$DEST/$FILE"
	yes | do_chroot apt install "/$FILE"
	rm -f "$DEST/$FILE"
}

rm "$DEST/etc/resolv.conf"
cp /etc/resolv.conf "$DEST/etc/resolv.conf"

do_chroot apt-key add - < rootfs/ayufan-deb-ayufan-eu.gpg
echo -n UTC > "$DEST/etc/timezone"

# Configure package sources
cat > "$DEST/etc/apt/sources.list.d/ayufan-rock64.list" <<EOF
deb http://deb.ayufan.eu/orgs/ayufan-rock64/releases /

# uncomment to use pre-release kernels and compatibility packages
# deb http://deb.ayufan.eu/orgs/ayufan-rock64/pre-releases /
EOF

cat > "$DEST/etc/apt/sources.list.d/ayufan-rock64-pre-releases.list" <<EOF
deb http://deb.ayufan.eu/orgs/ayufan-rock64/pre-releases /
EOF

# Add non-free packages
sed -i 's/main contrib$/main contrib non-free/g' $DEST/etc/apt/sources.list

# Configure system
cat > "$DEST/etc/hostname" <<EOF
$MODEL
EOF

cat > "$DEST/etc/fstab" <<EOF
tmpfs /tmp tmpfs defaults,nosuid,nodev 0 0
LABEL=boot /boot/efi vfat defaults,sync 0 2
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

mkdir -p "$DEST/etc/flash-kernel"

cat > "$DEST/etc/flash-kernel/machine" <<EOF
$MODEL
EOF

export DEBIAN_FRONTEND=noninteractive

do_chroot apt-get -y update

if [[ -n "$USE_EATMYDATA" ]]; then
	# Disable fsyncs to speed-up build process
	do_chroot apt-get -y install eatmydata

	export CHROOT_PREFIX="eatmydata --"
fi

do_chroot locale-gen en_US.UTF-8

do_chroot apt-get -y install dosfstools curl xz-utils iw rfkill wpasupplicant openssh-server alsa-utils \
	nano git build-essential vim jq wget ca-certificates software-properties-common dirmngr \
	gdisk parted figlet htop fake-hwclock usbutils sysstat fping iperf3 iozone3 ntp \
	network-manager psmisc u-boot-tools ifupdown resolvconf \
	net-tools mtd-utils rsync device-tree-compiler debsums pciutils \
	initramfs-tools cifs-utils command-not-found

if [[ "$DISTRIB" == "debian" ]]; then
	do_chroot apt-get -y install firmware-realtek
elif [[ "$DISTRIB" == "ubuntu" ]]; then
	do_chroot apt-get -y install landscape-common linux-firmware
fi

do_chroot fake-hwclock save

for arch in $EXTRA_ARCHS; do
	if [[ "$arch" != "$BUILD_ARCH" ]]; then
		do_chroot dpkg --add-architecture "$arch"
		do_chroot apt-get update -y
		do_chroot apt-get install -y "libc6:$arch" "libstdc++6:$arch"
	fi
done

for package in "$@"; do
	do_install "$package"
done

if [[ "$DEBUSER" != "root" ]]; then
	do_chroot adduser --gecos "$DEBUSER" --disabled-login "$DEBUSER" --uid 1000
	do_chroot chown -R 1000:1000 "/home/$DEBUSER"
	do_chroot usermod -a -G sudo,audio,adm,input,video,plugdev,ssh,lp,lpadmin "$DEBUSER"
fi

# Change and expire password
echo "$DEBUSER:$DEBUSERPW" | do_chroot chpasswd
do_chroot passwd -e "$DEBUSER"

case "$VARIANT" in
	mate)
		do_chroot /usr/local/sbin/install_desktop.sh mate
		do_chroot systemctl set-default graphical.target
		;;

	i3)
		do_chroot /usr/local/sbin/install_desktop.sh i3
		do_chroot systemctl set-default graphical.target
		;;

	lxde)
		do_chroot /usr/local/sbin/install_desktop.sh lxde
		do_chroot systemctl set-default graphical.target
		;;

	openmediavault)
		do_chroot /usr/local/sbin/install_openmediavault.sh
		;;

	containers)
		do_chroot /usr/local/sbin/install_container_linux.sh
		;;
esac

do_chroot apt-get dist-upgrade -y

do_chroot systemctl enable ssh-keygen

sed -i 's|After=rc.local.service|#\0|;' "$DEST/lib/systemd/system/serial-getty@.service"
rm -f "$DEST/etc/apt/sources.list.d/ayufan-rock64-pre-releases.list"
rm -f "$DEST/etc/resolv.conf"
rm -f "$DEST"/etc/ssh/ssh_host_*
do_chroot ln -s /run/resolvconf/resolv.conf /etc/resolv.conf
do_chroot apt-get clean

# List all installed packages
do_chroot apt list --installed > "$DEST/all-packages.txt"

# Bring back folders
mkdir -p "$DEST/lib"
mkdir -p "$DEST/usr"

# Clean up
rm -f "$DEST/usr/bin/qemu-arm-static"
rm -f "$DEST/usr/bin/qemu-aarch64-static"
rm -f "$DEST/usr/sbin/policy-rc.d"
rm -f "$DEST/usr/local/bin/mdadm"
rm -f "$DEST/var/lib/dbus/machine-id"
rm -f "$DEST/etc/flash-kernel/machine"
: > "$DEST/etc/machine-id"
rm -f "$DEST/SHA256SUMS"

echo "Done - installed rootfs to $DEST"
