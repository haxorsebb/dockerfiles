FROM phusion/baseimage:0.9.22
MAINTAINER Sebastian Hültenschmidt <s.hueltenschmidt@kernel-consulting.de>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
        samba \
	winbind \
	libnss-winbind \
	krb5-user \
	acl \
	ntp \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*



# Add startup scripts
RUN mkdir -p /etc/my_init.d
COPY samba_setup.sh ntpd_setup.sh /etc/my_init.d/

# Add services
RUN mkdir /etc/service/20_samba
COPY samba_run.sh /etc/service/20_samba/run
COPY samba_finish.sh /etc/service/20_samba/finish

RUN mkdir /etc/service/10_ntpd
COPY ntp.conf /etc/ntp.conf
COPY ntpd_run.sh /etc/service/10_ntpd/run
COPY ntpd_finish.sh /etc/service/10_ntpd/finish

RUN mkdir /etc/service/30_chgrp_users
COPY chgrp_users_run.sh /etc/service/30_chgrp_users/run
COPY chgrp_users_finish.sh /etc/service/30_chgrp_users/finish

RUN sed -i "s/passwd:         compat/passwd:         compat winbind/" /etc/nsswitch.conf && sed -i "s/group:          compat/group:          compat winbind/" /etc/nsswitch.conf 


VOLUME ["/var/lib/samba"]
VOLUME ["/shares"]
VOLUME ["/var/log"]


#According to https://wiki.samba.org/index.php/Samba_AD_DC_Port_Usage
# DNS
EXPOSE	53 53/udp 88 88/udp 135 137/udp 138/udp 139 389 389/udp 445 464 464/udp 636 49152-49200 3268 3269 123/udp

CMD ["/sbin/my_init"]
