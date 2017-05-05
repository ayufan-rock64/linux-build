#!/bin/sh

set -xe

#Install relevant libraries and applications
add-apt-repository -y ppa:rvm/smplayer
add-apt-repository -y ppa:longsleep/ubuntu-pine64-flavour-makers
apt-get -y update
apt-get -y install aisleriot build-essential emacs gcc geany gimp git gnomine gnome-sudoku htop libpixman-1-dev libvdpau-dev libvdpau-sunxi1 mplayer scratch smplayer smplayer-skins smplayer-themes smtube vim

apt-get -y upgrade
apt-get -y update
