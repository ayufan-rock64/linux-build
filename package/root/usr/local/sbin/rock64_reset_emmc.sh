#!/bin/bash

if [[ "$1" != "--force" ]]; then
    MNT_DEV=$(findmnt / -n -o SOURCE)
    if [[ "$MNT_DEV" == /dev/mmcblk0* ]]; then
        echo "Cannot reset when running from eMMC, use: $0 --force."
        exit 1
    fi
fi

if [[ -d /sys/bus/platform/drivers/dwmmc_rockchip/ff520000.dwmmc ]]; then
    echo "Unbinding..."
    echo ff520000.dwmmc > /sys/bus/platform/drivers/dwmmc_rockchip/unbind
fi

echo "Binding..."
echo ff520000.dwmmc > /sys/bus/platform/drivers/dwmmc_rockchip/bind

echo "Finished"
