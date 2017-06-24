#!/bin/bash

set -xe

# Based on https://github.com/armbian/build/blob/b13e92911e91e34b0b9189c704f3186a0b3788f0/scripts/customize-image.sh.template#L31

#Add OMV source.list and Update System
cat > /etc/apt/sources.list.d/openmediavault.list <<- EOF
deb http://packages.openmediavault.org/public erasmus main
# deb https://openmediavault.github.io/packages/ erasmus main
## Uncomment the following line to add software from the proposed repository.
deb http://packages.openmediavault.org/public erasmus-proposed main
# deb https://openmediavault.github.io/packages/ erasmus-proposed main

## This software is not part of OpenMediaVault, but is offered by third-party
## developers as a service to OpenMediaVault users.
# deb http://packages.openmediavault.org/public erasmus partner
EOF

# Add OMV and OMV Plugin developer keys
debconf-apt-progress -- apt-get update
apt-get --yes --force-yes --allow-unauthenticated install openmediavault-keyring
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7AA630A1EDEE7D73

# install debconf-utils, postfix and OMV
debconf-set-selections <<< "postfix postfix/mailname string openmediavault"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'No configuration'"
apt-get -y install \
    debconf-utils postfix

# install openmediavault
apt-get --yes install openmediavault

# install OMV extras, enable folder2ram, tweak some settings
FILE=$(mktemp)
wget http://omv-extras.org/openmediavault-omvextrasorg_latest_all3.deb -qO $FILE && dpkg -i $FILE && rm $FILE
/usr/sbin/omv-update
# use folder2ram instead of log2ram with OMV
apt-get -y install openmediavault-flashmemory
sed -i -e '/<flashmemory>/,/<\/flashmemory>/ s/<enable>0/<enable>1/' \
    -e '/<ssh>/,/<\/ssh>/ s/<enable>0/<enable>1/' /etc/openmediavault/config.xml
/usr/sbin/omv-mkconf flashmemory
systemctl disable log2ram
/sbin/folder2ram -enablesystemd
sed -i 's|-j /var/lib/rrdcached/journal/ ||' /etc/init.d/rrdcached

#FIX TFTPD ipv4
[ -f /etc/default/tftpd-hpa ] && sed -i 's/--secure/--secure --ipv4/' /etc/default/tftpd-hpa

# init OMV
/usr/sbin/omv-initsystem

# some performance tuning
grep -q ondemand /etc/default/cpufrequtils && sed -i '/^exit\ 0/i \
	echo ondemand >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor \
	sleep 0.1 \
	cd /sys/devices/system/cpu \
	for i in cpufreq/ondemand cpu0/cpufreq/ondemand cpu4/cpufreq/ondemand ; do \
	if [ -d $i ]; then \
	echo 1 >${i}/io_is_busy \
	echo 25 >${i}/up_threshold \
	echo 10 >${i}/sampling_down_factor \
	fi \
	done \
	' /etc/rc.local

echo "* * * * * root for i in \`pgrep \"ftpd|nfsiod|smbd|afpd|cnid\"\` ; do ionice -c1 -p \$i ${XU4_HMP_Fix}; done >/dev/null 2>&1" \
    >/etc/cron.d/make_nas_processes_faster
chmod 600 /etc/cron.d/make_nas_processes_faster
