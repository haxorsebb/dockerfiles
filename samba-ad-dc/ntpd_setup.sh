#!/bin/sh

set -e

info () {
    echo "[INFO] $@"
}
# Check if ntpd is setup
[ -f /var/lib/samba/.setup ] && exit 0

#copy ntp.conf to /var/lib/samba to make it accessible from outside
cp /etc/ntp.conf /var/lib/samba
mkdir /var/lib/samba/ntp_signd/
chown root:ntp /var/lib/samba/ntp_signd
chmod 0750 /var/lib/samba/ntp_signd

