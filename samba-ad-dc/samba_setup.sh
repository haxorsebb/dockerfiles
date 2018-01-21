#!/bin/sh

set -e

info () {
    echo "[INFO] $@"
}

# Check if samba is setup
[ -f /var/lib/samba/.setup ] && exit 0

# Require $SAMBA_REALM to be set
: "${SAMBA_REALM:?SAMBA_REALM needs to be set}"

# If $SAMBA_PASSWORD is not set, generate a password
SAMBA_PASSWORD=${SAMBA_PASSWORD:-`(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c20; echo) 2>/dev/null`}
info "Samba password set to: $SAMBA_PASSWORD"

# Populate $SAMBA_OPTIONS
SAMBA_OPTIONS=${SAMBA_OPTIONS:-}

[ -n "$SAMBA_DOMAIN" ] \
    && SAMBA_OPTIONS="$SAMBA_OPTIONS --domain=$SAMBA_DOMAIN" \
    || SAMBA_OPTIONS="$SAMBA_OPTIONS --domain=${SAMBA_REALM%%.*}"

[ -n "$SAMBA_HOST_IP" ] && SAMBA_OPTIONS="$SAMBA_OPTIONS --host-ip=$SAMBA_HOST_IP"

# Fix nameserver
#echo "search ${SAMBA_REALM}\nnameserver $SAMBA_HOST_IP\nameserver $SAMBA_DNS_FORWARDER" > /etc/resolv.conf
#fix hosts 
#echo "127.0.0.1     localhost localhost.localdomain\n$SAMBA_HOST_IP `hostname`.${SAMBA_REALM} `hostname`" >/etc/hosts

# Provision domain
rm -f /etc/samba/smb.conf
rm -rf /var/lib/samba/*
samba-tool domain provision \
    --use-rfc2307 \
    --realm=${SAMBA_REALM} \
    --adminpass=${SAMBA_PASSWORD} \
    --server-role=dc \
    --dns-backend=SAMBA_INTERNAL \
    $SAMBA_OPTIONS \
    --option="bind interfaces only =yes" \
    --option="interfaces = $SAMBA_HOST_IP 127.0.0.1" \
    --use-xattrs=yes \
    --option="idmap config * : backend = tdb" \
    --option="idmap config * : range = 900000-999999" \
    --option="idmap config $SAMBA_DOMAIN : backend = ad " \
    --option="idmap config $SAMBA_DOMAIN : schema_mode = rfc2307" \
    --option="idmap config $SAMBA_DOMAIN : range = $SAMBA_UID_START-900000" \
    --option="winbind nss info = rfc2307" \
    --option="winbind use default domain = yes"


# Move smb.conf
mv /etc/samba/smb.conf /var/lib/samba/private/smb.conf

# Update dns-forwarder if required
[ -n "$SAMBA_DNS_FORWARDER" ] \
    && sed -i "s/dns forwarder = .*/dns forwarder = $SAMBA_DNS_FORWARDER/" /var/lib/samba/private/smb.conf
# add dynamic port range restriction
sed -i "s/rpc server dynamic port range = .*/rpc server dynamic port range = 49152-49200/" /var/lib/samba/private/smb.conf 

#move sysvol share to shares volume
mv /var/lib/samba/sysvol /shares
#fix smb.conf
sed -i "s+/var/lib/samba/sysvol+/shares/sysvol+" /var/lib/samba/private/smb.conf


#add users share
echo "[users]\n\tpath = /shares/users/\n\tread only = no\n\tforce create mode = 0600\n\tforce directory mode = 0700\n" >>/var/lib/samba/private/smb.conf
#create users folder
mkdir -p /shares/users/
# chgrp -R "Domain Users" /shares/users/
chmod 2750 /shares/users/

cat /var/lib/samba/private/smb.conf

cp /var/lib/samba/private/krb5.conf /etc

#setup ntp
/etc/my_init.d/ntpd_setup.sh

# Mark samba as setup
touch /var/lib/samba/.setup

# Setup only?
[ -n "$SAMBA_SETUP_ONLY" ] && exit 127 || :
