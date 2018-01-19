#!/bin/sh

set -e

[ -f /var/lib/samba/.setup ] || {
    >&2 echo "[ERROR] ntpd is not setup yet, which should happen automatically. Look for errors!"
    exit 127
}

ntpd -n -c /var/lib/samba/ntp.conf
