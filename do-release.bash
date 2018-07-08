#!/bin/bash

if [[ $# -lt 1 ]] || [[ $# -gt 3 ]]; then
  echo "usage: $0 <release-version> [--force] [--dry-run]"
  exit 1
fi

if [[ " $@ " =~ " --force " ]] && ! git diff-files --quiet; then
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

echo "Adding changes..."
git add RELEASE.md Makefile.versions.mk

echo "Committing $1..."
cat <<EOF | git commit -F -
v$1

$(cat Makefile.versions.mk)
EOF

if [[ " $@ " =~ " --force " ]]; then
  git tag "$1" -f
else
  git tag "$1"
fi

echo "Pushing..."
git push origin "master" "$@"

echo "Done."
