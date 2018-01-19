FROM phusion/baseimage:0.9.22
MAINTAINER Sebastian Hültenschmidt <s.hueltenschmidt@kernel-consulting.de>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
        samba \
	winbind \
	krb5-user \
	ntp \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add startup scripts
RUN mkdir -p /etc/my_init.d
COPY samba_setup.sh ntpd_setup.sh /etc/my_init.d/

# Add services
RUN mkdir /etc/service/samba
COPY samba_run.sh /etc/service/samba/run
COPY samba_finish.sh /etc/service/samba/finish

RUN mkdir /etc/service/ntpd
COPY ntp.conf /etc/ntp.conf
COPY ntpd_run.sh /etc/service/ntpd/run
COPY ntpd_finish.sh /etc/service/ntpd/finish

VOLUME ["/var/lib/samba"]
VOLUME ["/shares"]

#According to https://wiki.samba.org/index.php/Samba_AD_DC_Port_Usage
# DNS
EXPOSE	53
EXPOSE	53/udp
# Kerberos
EXPOSE  88
EXPOSE 	88/udp
# End Point Mapper (DCE/RPC Locator Service)
EXPOSE	135
# NetBIOS Name Service
EXPOSE	137/udp
# NetBIOS Datagram
EXPOSE	138/udp
# NetBIOS Session
EXPOSE	139
# LDAP
EXPOSE	389
EXPOSE 	389/udp
# SMB over TCP
EXPOSE	445
# Kerberos kpasswd
EXPOSE	464
EXPOSE 	464/udp
# LDAPS
EXPOSE	636
# Dynamic RPC Ports --shortened to relieve docker - need matching smb.conf - originally 49152-65535     tcp
EXPOSE	49152-49200
# Global Catalog
EXPOSE	3268
# Global Catalog SSL
EXPOSE	3269
#ntpd
EXPOSE	123/udp

CMD ["/sbin/my_init"]
