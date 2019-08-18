#!/bin/bash

groups() {
  for group in $(id -G); do
    echo "--group-add=$group"
  done
}

ENTRYPOINT="--entrypoint=/bin/bash"
if [[ -n "$@" ]]; then
  ENTRYPOINT=""
fi

docker run \
  --rm \
  --interactive \
  --tty \
  --device=/dev/kvm \
  --user="$(id -u)" \
  $(groups) \
  --workdir=/src \
  --volume="$(pwd):/src" \
  --security-opt=label=disable \
  $ENTRYPOINT \
  godebos/debos "$@"
