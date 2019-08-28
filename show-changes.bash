#!/bin/bash

set -eo pipefail

if [[ $# -ne 1 ]] && [[ $# -ne 2 ]]; then
  echo "usage: $0 <old-release> [new-release]"
  exit 1
fi

show_diff() {
  PREVIOUS="PREVIOUS_${2}"
  LATEST="LATEST_${2}"
  PREVIOUS="${!PREVIOUS}"
  PREVIOUS="${PREVIOUS/$3/}"
  LATEST="${!LATEST}"
  LATEST="${LATEST/$3/}"

  if [[ "${PREVIOUS}" != "${LATEST}" ]]; then
    echo "- https://github.com/ayufan-rock64/$1/compare/${PREVIOUS}..${LATEST}"
  fi
}

echo "Reading package versions..."
eval $(git show "$1:Makefile.latest.mk" | sed "s/^LATEST_/PREVIOUS_/g")
eval $(git show "${2-HEAD}:Makefile.latest.mk")
echo

echo "Differences:"
show_diff linux-u-boot UBOOT_VERSION
show_diff linux-kernel KERNEL_VERSION "-g*"
show_diff linux-package PACKAGE_VERSION
echo
