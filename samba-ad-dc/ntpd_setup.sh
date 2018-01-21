#!/bin/sh

set -e

info () {
    echo "[INFO] $@"
}
# Check if ntpd is setup
[ -f /var/lib/samba/.setup ] && exit 0

#copy ntp.conf to /var/lib/ntp to make it accessible from outside
cp /etc/ntp.conf /etc/ntp
#chown -R root:ntp /etc/ntp
#chmod -R 777 /etc/ntp
mkdir /var/lib/samba/ntp_signd/
chown root:ntp /var/lib/samba/ntp_signd
chmod 0750 /var/lib/samba/ntp_signd


