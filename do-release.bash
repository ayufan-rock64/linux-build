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

set -e

echo "Edit changeset:"
if which editor &>/dev/null; then
  editor RELEASE.md
else
  vi RELEASE.md
fi

echo "OK?"
read PROMPT

echo "Reading package versions..."
make generate-versions > Makefile.versions.mk
cat Makefile.versions.mk

echo "OK?"
read PROMPT

echo "Adding changes..."
git add RELEASE.md Makefile.versions.mk

echo "Creating tag..."
git add Makefile.versions.mk
cat <<EOF | git commit $COMMIT_FLAGS -F -
v$RELEASE

$(cat Makefile.versions.mk)
EOF

git tag "$RELEASE" $TAG_FLAGS

echo "Pushing..."
git push origin "$RELEASE" $PUSH_FLAGS
git push origin master $PUSH_FLAGS

echo "Done."
