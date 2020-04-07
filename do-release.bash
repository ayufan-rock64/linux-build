#!/bin/bash

if [[ "$DEBUG" == 1 ]]; then
  set -x
fi

usage() {
  echo "usage: $0 <release-version> [--force] [--dry-run]"
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

RELEASE="$1"
COMMIT_FLAGS=""
TAG_FLAGS=""
PUSH_FLAGS=""
NO_DIRTY=1
shift

for arg; do
  case "$arg" in
    --force)
      TAG_FLAGS="$TAG_FLAGS --force"
      PUSH_FLAGS="$PUSH_FLAGS --force"
      NO_DIRTY=0
      ;;

    --dry-run)
      PUSH_FLAGS="$PUSH_FLAGS --dry-run"
      ;;

    *)
      usage
      ;;
  esac
done

if [[ "$NO_DIRTY" == "1" ]] && ! git diff-files --quiet; then
  echo "dirty working tree, commit changes"
  exit 1
fi

set -eo pipefail

echo "Reading package versions..."
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

eval $(git show "HEAD:Makefile.latest.mk" | sed "s/^LATEST_/PREVIOUS_/g")

git checkout Makefile.latest.mk
make generate-latest > Makefile.latest.mk
source Makefile.latest.mk
echo

echo "Differences:"
# Show diff for `linux-build`
if ! git describe --tags --exact &>/dev/null; then
  PREVIOUS_TAG=$(git rev-parse --short $(git describe --tags --abbrev=0))
  CURRENT_HEAD=$(git rev-parse --short HEAD)
  echo "- https://github.com/ayufan-rock64/linux-build/compare/${PREVIOUS_TAG}..${CURRENT_HEAD}"
fi

# Show diff for additional repositories
show_diff linux-mainline-u-boot UBOOT_VERSION
show_diff linux-mainline-kernel KERNEL_VERSION "-g*"
show_diff linux-rootfs ROOTFS_VERSION
show_diff linux-package PACKAGE_VERSION
echo

echo "OK?"
read PROMPT
echo

echo "Edit changeset:"
if which editor &>/dev/null; then
  editor RELEASE.md
else
  vi RELEASE.md
fi

echo "OK?"
read PROMPT
echo

echo "Adding changes..."
git add RELEASE.md Makefile.latest.mk
echo

echo "Creating tag..."
git add Makefile.latest.mk
cat <<EOF | git commit $COMMIT_FLAGS --allow-empty -F -
v$RELEASE

$(cat Makefile.latest.mk)
EOF

git tag "$RELEASE" $TAG_FLAGS
echo

echo "Pushing..."
git push origin HEAD "$RELEASE" $PUSH_FLAGS
echo

echo "Done."
