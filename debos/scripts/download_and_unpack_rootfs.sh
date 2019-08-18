#!/bin/bash

if [[ $# -ne 3 ]] && [[ $# -ne 4 ]]; then
  echo "usage: $0 <stretch|buster|bionic|disco> <minimal|...> <armhf|arm64> [version]"
  exit 1
fi

set -eo pipefail

DISTRO="$1"
VARIANT="$2"
ARCH="$3"
VERSION="$4"

if [[ -z "$VERSION" ]]; then
  VERSION=$(curl -s https://api.github.com/repos/ayufan-rock64/linux-rootfs/releases/latest | jq -r ".tag_name")
fi

case "$DISTRO" in
	bionic|disco)
		ROOTFS="https://github.com/ayufan-rock64/linux-rootfs/releases/download/${VERSION}/ubuntu-${DISTRO}-${VARIANT}-${VERSION}-${ARCH}.tar.xz"
		FALLBACK_ROOTFS="https://github.com/ayufan-rock64/linux-rootfs/releases/download/${VERSION}/ubuntu-${DISTRO}-minimal-${VERSION}-${ARCH}.tar.xz"
		TAR_OPTIONS="-J --strip-components=1 binary"
		;;

	stretch|buster)
		ROOTFS="https://github.com/ayufan-rock64/linux-rootfs/releases/download/${VERSION}/debian-${DISTRO}-${VARIANT}-${VERSION}-${ARCH}.tar.xz"
		FALLBACK_ROOTFS="https://github.com/ayufan-rock64/linux-rootfs/releases/download/${VERSION}/debian-${DISTRO}-minimal-${VERSION}-${ARCH}.tar.xz"
		TAR_OPTIONS="-J --strip-components=1 binary"
		;;

	*)
		echo "Unknown distribution: $1"
		exit 1
		;;
esac

CACHE_ROOT="$ARTIFACTDIR/tmp"
mkdir -p "$CACHE_ROOT"
TARBALL="${CACHE_ROOT}/$(basename $ROOTFS)"

if [[ ! -e "$TARBALL" ]]; then
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
tar -xf "$TARBALL" -C "$ROOTDIR" $TAR_OPTIONS
rm "$ROOTDIR/SHA256SUMS"
echo "OK"
