#!/bin/sh

set -xe

#Install relevant libraries and applications
echo "\nInstalling programs...\n"
add-apt-repository -y ppa:rvm/smplayer
apt-get -y update
apt-get -y install aisleriot build-essential emacs gcc geany gimp git gnomine gnome-sudoku htop libpixman-1-dev libvdpau-dev mplayer scratch smplayer smplayer-skins smplayer-themes smtube vim
echo "\nInstalled!!!\n"


#Solve video issue of cannot stream video smoothly
echo "\nFix Pinebook video...\n"
git clone https://github.com/linux-sunxi/libcedrus.git
make -C libcedrus install 
git clone https://github.com/linux-sunxi/libvdpau-sunxi.git
make -C libvdpau-sunxi install
ln -s /usr/lib/aarch64-linux-gnu/vdpau/libvdpau_sunxi.so.1 /usr/lib/libvdpau_nvidia.so
rm -rf libcedrus libvdpau-sunxi
echo "\nPinebook video is fixed!!!\n"


#Remove scripts that may cause the system crash
#rm -rf /usr/local/sbin/pine64*
apt-get -y upgrade
apt-get -y update
