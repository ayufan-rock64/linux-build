#!/bin/bash

# Install rpimonitor on a pine64 running ubuntu (may work for debian also)
#
# Run latest version directly from github when logged in as root / sudo with
# wget -q -O - https://raw.githubusercontent.com/pfeerick/pine64-scripts/master/install-rpimonitor.sh | /bin/bash
#
# Original code lifted from http://kaiser-edv.de/tmp/4U4tkD/install-rpi-monitor-for-a64.sh
# Original code written by tkaiser, as well as assuggestions for a deriverative work
#
# This modification written by pfeerick

if [ "$(id -u)" != "0" ]; then
        echo "This script must be executed as root. Exiting" >&2
        exit 1
fi

useEncodedPublicKey()
{
    echo -e "\nUsing backup copy of public key for Armbian package list"
    cd /tmp && echo "LS0tLS1CRUdJTiBQR1AgUFVCTElDIEtFWSBCTE9DSy0tLS0tClZlcnNpb246IFNLUyAxLjEuNgpD
b21tZW50OiBIb3N0bmFtZToga2V5cy5mc3Bwcm9kdWN0aW9ucy5iaXoKCm1RSU5CRlVHOHA0QkVB
REdsc2VHRm1kampmbW9YdEhwWnhxZ1lIR3dlQ25HWjA1TGlHZ0VWZ2J2NVNyVHNKc3lPOEg4UnlC
UAp4Z2JwS0VZK0pDVjFJbFlRUGFFM1RpbDEra3FtUjRYTktidWZqRXVxQVY0VkpXMzI2N3RZUnVK
MzA4RTcwcTdrcFFTc0VBV0wKVlkreFYvbDVzdEF1cHA0L3dGNUJQZEFqVzdnTHVpY1BucW9LSzBq
Y2ZyanV2ZDQ1V0ZocGpMMVNkZDBQbklMZWh6MHRvNlIyCkg5TXNXK1ZZWVBGenRkakJNLzc4VUQ4
Z3JNY0NtLzdNejhFTlJLQ25US3JnajRicFdBMGtQRUhOQmZhb1FRVWs1ZkNKWU5NTAp2TE1JR1pj
V2VHT1BvK3lGbmw0QzZxVEVnczBnNy8wRTU2eWNhUURKK2dCQ0g5WU5hOGozZUgvdDF2TU4wRVJY
aU9RZjZXWGcKUmloT0QxZmNuWkZtY3pRRlQzR0dodjN5Ky9jVXBzVWxtaGhKNnRldGl1WE51VGZy
bDNNKzk5cVVxNS84aWlxMjkyTUNtbjVzCjBCRU9peWZRMmwydVptanlEVU8rNGxMOW8zTVgwVzVY
cDFwdUUycDQyYit3NDU4YURLdXVGdkJ6Vk1pVTUxSnM2RFpuYWh4dQoycytORHp0RGd1dDdwK1A2
MFVCQ2JsdFhFQjBaSXlXVEFrS0N3SWxhcFo5eURpSHFYaU5sdVRkQmlGV0d5VTN4bGI0ZnVRencK
bHd2bVMzeXo0QWs1R0NkRHBpTG1Kb0hPS1Y2cTg1VmFJNFQzZ2l4eDRKd0VmZGluY09HZmVwU1dG
bWJFc0R1Vng1dmJEVjVECndiM29BZzgwenAzVy91TnlYN0c0MXVJR0ROelpMODJwMlh0Z0d6a2po
RWJLQW5OYXZ3QVJBUUFCdEQxSloyOXlJRkJsWTI5MgpibWxySUNoTWFuVmliR3BoYm1Fc0lGTnNi
M1psYm1saEtTQThhV2R2Y2k1d1pXTnZkbTVwYTBCbmJXRnBiQzVqYjIwK2lRSTQKQkJNQkFnQWlC
UUpWQnZLZUFoc0RCZ3NKQ0FjREFnWVZDQUlKQ2dzRUZnSURBUUllQVFJWGdBQUtDUkNUMW9pZm53
NTQxVDZXCkQvMFgrTEQ5R20xTlZnWmhySDM1b1EzenN0RU5yVGpENkxGK2tUK3poZTZRUjliQWRP
bWViN0plNDIzeS9VWTNuU2FKbFMvTwpXc0pzODl0WFV5RTJqYnh0TEFwTjZPTVRac0l4amd5ZzNm
amJIVi9sdy94R3ArY3FIalgrQXk1UVp1ZEpWeEdKTjdXSmFSR3gKeW1qb3A3RVg0Q0hpaWRHWlBa
b0RUMjNXQXJMaWE3RThNTEIvb0szd1c2azlRbGMyU3JobGR6cHVTbU93SFFYOXB4bXk5ZGdmClph
MmE5dzFjRXZrdERucml6UG1meHdZYUMzOEZLUnF6MUk4Q25QTUVTVkorNm1MRVl4V0p2SkFOdVZ2
cmhxT3Rqa1k2eUkwdQpTT0ZIc21nY2krM1gyYzdXV2hsb0t1Yi9QZjdUdE02dGw2UkNIZkt2bnNy
VFpQdnhQMS9DZ3pRaUFJVFdwcEJsb2xuU1JIWHAKM25vdENGMXJWYmdJbndWdUNaQ3VXUEp2SEM2
UjN0OS9VZ0VTYW8wdEV3cjRtdzdqTnd0c3pXb3U0cll6akVBTUUvTy9rQkJXClBiRFVSbS80Ujhs
MFhTbkcwemhlUEt2NWlDemVRYkl6VWVBRDFEY3ZrN2ZhbGdubDlGWDkvTFpDWTFrRXdGTWYyREcw
M2x3Rwo3YzRJQ1NWQXowcE5FUFpkcXB5Q2w4MlZLa0RuZThQQTBSYi91UElPUVkzYUR1OGJnY1BR
dW9rbVJSTDRyd2RuUkNWcjBBRkQKWmhWUW5VamNkeThBdkVQZXllMmZOZExodGUrS1VXaXlGTldw
MnZXMkxiSjlHeFBzdGFGaWhYWkJjQ0VwR1dzTkhlYkRkMUttCk5HeVBLY3F6YUlmekhQTFA4K2Vl
MmRlS0E5NVBWelYzaVRMK09ia0NEUVJWQnZLZUFSQUF2R2FLQ0hER2wwZUM3ZkZvazVzUApxMVdh
dHRwcVE5UUwwQmdaOTVWUUxuKzcvMW5YbUtzRGZDd0N2bkJHcUxYelBReXZXaENiQ1ROOW9Za3Fv
a0JYMkNoMXpPSUEKQnludytVQ00rS3laY21jaVlaSUYyMU9zdFdNTTBuUTA2am5vNUhxMXZTSGxn
VGthYVlXWllvcVhvY01DUzlsbHZJMk5WRzM0CmJjYWsxaEFoOUVrZm1UaFZ0dERlR1pQK29zcXQy
bWVmcENBVklUUDFlUVdVM1JVQnBPS05wdGhwTHhNaHkrbDdtOHRta0xIMwpGdXF3WnZWalkyNDF3
MW80QVdWcEpEL0pkT3VBZkh0ZjcvVURQY2hTWkxlOUVhOFkrYm5raVp4Z1NST3RGclJ6YlZ3UDFJ
ZDQKUktUNDRCd0tNclh1OEdpWkFQdlFxNUN2SU5xWkRNcWlxcTQrakZKUE1Wb3J0dXhYc2tSaDFk
VllPaW9IMW11emVIZjU2MC9CCkxXK21CdUVkK3hFMGdkNlNYUmdQaWZsUk95bHBKQ2I5UXhpOE9m
cTZGRUhCZko4bUh6NDlkNjBxeVhaTmRObHhMaEEzZGZPdgphYWhGQmdYd05Td2phazB6ZjZScHVm
QWtoOFNpNWpjM1FoN2xwdXdzQmVseU51N3RCYkwyeThXblVlei8rYWVYOXNCU3FzNzgKbWZwRGRM
QUduSWxUOVljamtIbDVXMzg1ampoQkFocEFnaUxJc2RTUktjYzJDSTM0VmY3NzVjTExJWXJjQnJq
Vk1MWUJ3RWlaCkhPUE85MExuaXpneDFsNXQxd0cyQWE1T2FyVFRVUElnTWlUVXRLUFE4Qm1jakdN
WmlhdmRKd3FHVXppREQraE1LY3hQVU1qeQpZaXUrbmdrSDFST3VDeE1BRVFFQUFZa0NId1FZQVFJ
QUNRVUNWUWJ5bmdJYkRBQUtDUkNUMW9pZm53NTQxV203RC9zRzBvdU0KNzFjNW1UK2VnZmYrUXhm
RXh5K0pCNC92TDFwTFNIYk1SOEF0QUpMTitZaDZFemVHbVcydGdhMEJrOUF4RWVrUXJhWHJNRmha
ClNwVDk4cUpubkRwZG96ZmVJQXlUd3ppdzlLOW9wQjBkVS8rTTNzVmlka0o1bXY0TFc2Q0phYVkz
cnNvbTBUSWpheEJ2WHFTZQphZEpGNFdHVUh6ZzNldys4YWgwWkc4U0RadTE5a2V0TjJjblRNQXRn
Tys1M0VwanFwazN1TUY1aE5hRUh0OXdWajJ0cS9hbkwKRXNsNFQ1VS9la1FuZHhjVEVzVjJLSVZT
b3llMzV5ZTRhYW0xZ1doVzlKSUZ0U2hoRXRYRC81T3Z0ajcwNllMVFA4NFU4eUhTCnR6TTZMTEdw
cU04YmIxUXNCVVdSVWhJS2lkbHRtTzlLalg2ckpadWh3a2NWSkpZUmRiZXRFWGJpU0l5ZU5aeTdi
QmU0RW4rZgpWY04wZWtCRDM2TGhNY1ZMOEYxTW50cjFMNXhmMGNGRXBGcEVvZFFVdmNheU5ncEky
eTdFSVBqS21LaFZ3VzVkeDM2UTBDc0MKbndjQytLZzZCTnpsaUk5SXMrb0EyQVZJYW5GUHZqdlN3
Zkc5cEgrMi91K0tCNEhUMlV4MUZCYkJpNUdBd28rY3UxZDRYQWM1CmJaSGRQbkFWdG5JTjlkS1J1
c1o4SUdIV0VkOFB3MGtSZXB1TmhTbVNOQUxRa1M2QitwcFFadG1vR3NCQ3FKZU1QeFF4ait5SQov
YkwzZG1BMlVYeG5HSjN2czJ5YkZ5SEczYW9vdktKZldWeXR4T0pmRzdxajFBQ3JPWU9YZWtXbGN3
NWxFaVlGY2NrdWtOcXEKRnYvQ1hoK0JaRmxRVDRERHZKbFkwL0tRRkZLb2dRPT0KPUkvUDgKLS0t
LS1FTkQgUEdQIFBVQkxJQyBLRVkgQkxPQ0stLS0tLQo=" | base64 --decode > keyfile

    if [ -f /tmp/keyfile ]; then
        apt-key add /tmp/keyfile
        local keyAddState=$?

        rm /tmp/keyfile

        if [ $keyAddState -ne 0 ]; then
            echo -e "\033[0;31m\nUnable to add backup public key... exiting\033[0m"

            if [ -f /etc/apt/sources.list.d/armbian.list ]; then
               #remove if not Armbian
               if [ ! -f /etc/armbian-release ]; then rm /etc/apt/sources.list.d/armbian.list; fi
            fi

            exit 2
        fi
    else
        echo -e "\033[0;31m\nUnable to use provided backup public key... exiting\033[0m"

        if [ -f /etc/apt/sources.list.d/armbian.list ]; then
           #remove if not Armbian
           if [ ! -f /etc/armbian-release ]; then rm /etc/apt/sources.list.d/armbian.list; fi
        fi

        exit 1
    fi
} #useEncodedPublicKey

PatchRPiMonitor_for_sun50iw1p1()
{
    echo -e "\nNow patching RPi-Monitor to deal correctly with A64"
    cd /etc/rpimonitor/ && echo "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" | base64 --decode | tar xzf -
   
   which systemctl >/dev/null 2>&1
   case $? in
        0)
            # Jessie|Xenial
            systemctl restart rpimonitor >/dev/null 2>&1
            ;;
        *)
            # Wheezy|Trusty
            /etc/init.d/rpimonitor stop >/dev/null 2>&1
            /etc/init.d/rpimonitor start >/dev/null 2>&1
            ;;
    esac
} # PatchRPiMonitor_for_sun50iw1p1

cleanupPackageLists()
{
    echo -e "\nCleaning up package lists"

    if [ -f /etc/apt/sources.list.d/armbian.list ]; then
        #remove if not Armbian
        if [ ! -f /etc/armbian-release ]; then 
            rm /etc/apt/sources.list.d/armbian.list
            apt-key del 9F0E78D5 >/dev/null 2>&1
            apt-get update
       fi
    fi
} # cleanupPackageLists

echo -e "$(date) Start RPi-Monitor installation\n"

echo -e "Checking for dpkg lock\c"
while true ; do
    fuser /var/lib/dpkg/lock >/dev/null 2>&1 || break
    sleep 3
    echo -e ".\c"
done

echo -e "\nAdding Armbian package list"
if [ ! -f /etc/apt/sources.list.d/armbian.list ]; then
    echo 'deb http://apt.armbian.com xenial main utils xenial-desktop' > \
    /etc/apt/sources.list.d/armbian.list

    apt-key adv --keyserver keys.gnupg.net --recv-keys 0x93D6889F9F0E78D5 >/dev/null 2>&1

    if [ $? -ne 0 ]; then
        useEncodedPublicKey
    fi
fi

echo -e "\nUpdating package lists"
apt-get update

echo -e "\nInstalling rpimonitor (this may take several minutes)..."
apt-get -f -qq -y install rpimonitor
/usr/share/rpimonitor/scripts/updatePackagesStatus.pl &

cleanupPackageLists

PatchRPiMonitor_for_sun50iw1p1

echo -e "\n$(date) Finished RPi-Monitor installation"
echo -e " \nNow you're able to enjoy RPi-Monitor at http://$((ifconfig -a) | sed -n '/inet addr/s/.*addr.\([^ ]*\) .*/\1/p' | grep -v '127.0.0.1' | head -1):8888"
