#!/bin/bash

if [[ "$(lsb_release -c -s)" != "jessie" ]]; then
	echo "This script only works on Debian/Jessie"
	exit 1
fi

echo "OpenMediaVault installation script"
echo "Script is based on Armbian, OMV and tkaiser work: https://github.com/armbian/build/blob/master/config/templates/customize-image.sh.template"
echo ""
echo "This script overwrites network interfaces."
echo "Make sure that you configured them in OpenMediaVault interface before rebooting."
echo ""

if [[ -t 0 ]]; then
	echo "In order to continue type YES or cancel:"
	while read PROMPT; do
		if [[ "$PROMPT" == "YES" ]]; then
			break
		fi
	done
fi

set -xe

#Add OMV source.list and Update System
cat > /etc/apt/sources.list.d/openmediavault.list <<- EOF
# deb http://packages.openmediavault.org/public erasmus main
deb https://openmediavault.github.io/packages/ erasmus main
## Uncomment the following line to add software from the proposed repository.
# deb http://packages.openmediavault.org/public erasmus-proposed main
deb https://openmediavault.github.io/packages/ erasmus-proposed main

## This software is not part of OpenMediaVault, but is offered by third-party
## developers as a service to OpenMediaVault users.
# deb http://packages.openmediavault.org/public erasmus partner
EOF

# Add OMV and OMV Plugin developer keys
apt-get update -y
apt-get --yes --force-yes --allow-unauthenticated install openmediavault-keyring
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7AA630A1EDEE7D73

# install debconf-utils, postfix and OMV
debconf-set-selections <<< "postfix postfix/mailname string openmediavault"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'No configuration'"
apt-get -y install debconf-utils postfix

# install openmediavault
apt-get --yes install openmediavault

# install OMV extras, enable folder2ram, tweak some settings
FILE=$(mktemp)
wget https://github.com/OpenMediaVault-Plugin-Developers/packages/raw/master/openmediavault-omvextrasorg_latest_all3.deb -qO $FILE && dpkg -i $FILE
/usr/sbin/omv-update

# FIX TFTPD ipv4
[ -f /etc/default/tftpd-hpa ] && sed -i 's/--secure/--secure --ipv4/' /etc/default/tftpd-hpa

# load OMV helpers
. /usr/share/openmediavault/scripts/helper-functions

# use folder2ram
apt-get -y install openmediavault-flashmemory
xmlstarlet ed -L -u "/config/services/flashmemory/enable" -v "1" ${OMV_CONFIG_FILE}

# enable ssh, but disallow root login
xmlstarlet ed -L -u "/config/services/ssh/enable" -v "1" ${OMV_CONFIG_FILE}
xmlstarlet ed -L -u "/config/services/ssh/permitrootlogin" -v "0" ${OMV_CONFIG_FILE}

# enable ntp
xmlstarlet ed -L -u "/config/system/time/ntp/enable" -v "1" ${OMV_CONFIG_FILE}

# improve netatalk performance
apt-get -y install openmediavault-netatalk
AFP_Options="mimic model = Macmini"
xmlstarlet ed -L -u "/config/services/afp/extraoptions" -v "$(echo -e "${AFP_Options}")" ${OMV_CONFIG_FILE}

# improve samba performance
SMB_Options="min receivefile size = 16384\nwrite cache size = 524288\ngetwd cache = yes\nsocket options = TCP_NODELAY IPTOS_LOWDELAY"
xmlstarlet ed -L -u "/config/services/smb/extraoptions" -v "$(echo -e "${SMB_Options}")" ${OMV_CONFIG_FILE}

# fix timezone
xmlstarlet ed -L -u "/config/system/time/timezone" -v "UTC" ${OMV_CONFIG_FILE}

# fix hostname
xmlstarlet ed -L -u "/config/system/network/dns/hostname" -v "$(cat /etc/hostname)" ${OMV_CONFIG_FILE}

# disable monitoring
xmlstarlet ed -L -u "/config/system/monitoring/perfstats/enable" -v "0" ${OMV_CONFIG_FILE}

# disable journal for rrdcached
sed -i 's|-j /var/lib/rrdcached/journal/ ||' /etc/init.d/rrdcached

# add eth0 interface
xmlstarlet ed -L \
	-s /config/system/network/interfaces -t elem -n interface \
	-s /config/system/network/interfaces/interface -t elem -n uuid -v 4fa8fd59-e5be-40f6-a76d-be6a73ed1407 \
	-s /config/system/network/interfaces/interface -t elem -n type -v ethernet \
	-s /config/system/network/interfaces/interface -t elem -n devicename -v eth0 \
	-s /config/system/network/interfaces/interface -t elem -n method -v dhcp \
	-s /config/system/network/interfaces/interface -t elem -n method6 -v manual \
	/etc/openmediavault/config.xml

# configure cpufreq
cat <<EOF >>/etc/default/openmediavault
OMV_CPUFREQUTILS_GOVERNOR=ondemand
OMV_CPUFREQUTILS_MINSPEED=0
OMV_CPUFREQUTILS_MAXSPEED=0
EOF

cat <<EOF >>/etc/rsyslog.d/omv-armbian.conf
:msg, contains, "do ionice -c1" ~
:msg, contains, "action " ~
:msg, contains, "netsnmp_assert" ~
:msg, contains, "Failed to initiate sched scan" ~
EOF

# update configs
/usr/sbin/omv-mkconf monit
/usr/sbin/omv-mkconf netatalk
/usr/sbin/omv-mkconf samba
/usr/sbin/omv-mkconf timezone
/usr/sbin/omv-mkconf collectd
/usr/sbin/omv-mkconf flashmemory
/usr/sbin/omv-mkconf ssh
/usr/sbin/omv-mkconf ntp
/usr/sbin/omv-mkconf cpufrequtils
/usr/sbin/omv-mkconf interfaces

# make sure that rrdcached does exist
mkdir -p /var/lib/rrdcached

# disable rrdcached
systemctl disable rrdcached

/sbin/folder2ram -enablesystemd
/sbin/folder2ram -mountall || true

# init OMV
# /usr/sbin/omv-initsystem
