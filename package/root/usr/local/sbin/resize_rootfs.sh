#!/bin/bash

set -xe

gdisk /dev/mmcblk0 <<EOF
x
e
m
d
7
n
7


EF00
c
7
root
w
Y
EOF

partprobe /dev/mmcblk0

resize2fs /dev/mmcblk0p7
