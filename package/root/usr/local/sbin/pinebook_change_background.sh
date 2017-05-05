#!/bin/sh

set -xe

#Add pinebook wallpaper
echo "\nChange Pinebook wallpaper..."
gsettings set org.mate.background picture-filename /usr/share/backgrounds/ubuntu-mate-pinebook/Pinebook-Wallpaper-6.jpg
echo "\nChanged!!!\n"
