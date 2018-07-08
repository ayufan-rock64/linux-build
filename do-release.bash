#!/bin/bash

if [[ "$DEBUG" == 1 ]]; then
  set -x
fi

usage() {
  echo "usage: $0 <release-version> [--amend] [--force] [--dry-run]"
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
AMEND=0
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

    --amend)
      COMMIT_FLAGS="$COMMIT_FLAGS --amend"
      TAG_FLAGS="$TAG_FLAGS --force"
      PUSH_FLAGS="$PUSH_FLAGS --force"
      AMEND=1
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

if [[ "$AMEND" == "1" ]] && ! git show -s --format=%B | grep --quiet "^LATEST_"; then
  echo "can only amend release commit"
  exit 1
fi

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

echo "Adding changes..."
git add RELEASE.md Makefile.versions.mk

echo "Creating temporary branch..."
git checkout $(git rev-parse HEAD) >/dev/null

echo "Committing $RELEASE..."
cat <<EOF | git commit $COMMIT_FLAGS -F -
v$RELEASE

$(cat Makefile.versions.mk)
EOF

git tag "$RELEASE" $TAG_FLAGS

echo "Checking master again..."
git checkout "master"

echo "Pushing..."
git push origin "$RELEASE" $PUSH_FLAGS

echo "Done."
