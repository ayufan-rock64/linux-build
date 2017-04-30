#!/bin/bash

set -xe

cd /sys/class/gpio

if [ ! -d gpio362 ]; then
	echo 362 > export
fi

cd gpio362
echo out > direction
echo 0 > value
